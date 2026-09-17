PADB = PixelArtDatabase

# Loads delayed video sources into shared blob URLs and manages playback for their media elements.
# Components decide when a video is active and use play, pause, and end to communicate its lifecycle.
class PADB.Components.VideoManager
  constructor: (@options = {}) ->
    # Default to fetching without a referrer so hosts cannot reject the application URL sent by native video loads.
    @fetchOptions = _.extend
      referrerPolicy: 'no-referrer'
    ,
      @options.fetchOptions

    # Source entries deduplicate fetches and keep their object URLs alive for this manager's lifetime.
    @_sourceEntriesByUrl = {}

    # Video states protect elements from asynchronous results that belong to an earlier source or activation.
    @_videoStates = []
    @_destroyed = false

    # Retry active videos during a user gesture when autoplay was blocked during a direct page load.
    @_onUserInteraction = => @_retryActiveVideos()
    $(document).on 'click', @_onUserInteraction

  play: (video, sourceUrl, options = {}) ->
    return Promise.resolve() if @_destroyed or not video

    videoState = @_videoStateFor video

    # End the previous binding before Blaze reuses a video element for another source.
    if videoState and videoState.sourceUrl isnt sourceUrl
      @end video
      videoState = null

    unless videoState
      videoState =
        video: video
        sourceUrl: sourceUrl
        active: false
        requestId: 0
        managedSourceAssigned: false

      @_videoStates.push videoState

    # Invalidate any earlier playback request and record the new playback policy.
    @_cancelVideoReadinessWait videoState
    videoState.active = true
    videoState.restart = if options.restart? then options.restart else false
    videoState.requestId++

    @_requestVideoPlayback videoState, videoState.requestId

  pause: (video) ->
    return unless video

    if videoState = @_videoStateFor video
      # Prevent a pending fetch or canplay event from restarting the video after it was paused.
      videoState.active = false
      videoState.requestId++
      @_cancelVideoReadinessWait videoState

    video.pause()

  end: (video) ->
    return unless video

    videoState = @_videoStateFor video
    return video.pause() unless videoState

    # Stop pending playback and remove the state before detaching the source.
    @pause video
    _.pull @_videoStates, videoState

    # Native sources are owned by their templates. Only detach blob sources assigned by this manager.
    if videoState.managedSourceAssigned and video.src is videoState.objectUrl
      video.removeAttribute 'src'
      video.load()

  destroy: ->
    return if @_destroyed

    @_destroyed = true
    $(document).off 'click', @_onUserInteraction

    # Detach every managed source before its object URL is revoked.
    @end videoState.video for videoState in @_videoStates[..]

    sourceEntries = _.values @_sourceEntriesByUrl

    # Abort requests that no longer have a component waiting for them.
    sourceEntry.abortController?.abort() for sourceEntry in sourceEntries

    videoObjectUrls = for sourceEntry in sourceEntries when sourceEntry.objectUrl
      sourceEntry.objectUrl

    @_sourceEntriesByUrl = {}

    # Give media elements a turn to release detached sources before revoking their object URLs.
    Meteor.defer ->
      URL.revokeObjectURL videoObjectUrl for videoObjectUrl in videoObjectUrls

  _requestVideoPlayback: (videoState, requestId) ->
    return unless @_videoStateIsCurrent videoState, requestId

    # Videos with native sources only need the playback part of the manager.
    return @_playVideoWhenReady videoState, requestId unless videoState.sourceUrl

    sourceEntry = @_sourceEntryForUrl videoState.sourceUrl

    if sourceEntry.objectUrl
      @_assignVideoSource videoState, sourceEntry.objectUrl
      return @_playVideoWhenReady videoState, requestId

    return if sourceEntry.failed

    videoObjectUrl = await @_loadSource videoState.sourceUrl, sourceEntry
    return unless videoObjectUrl
    return unless @_videoStateIsCurrent videoState, requestId

    @_assignVideoSource videoState, videoObjectUrl
    @_playVideoWhenReady videoState, requestId

  _sourceEntryForUrl: (sourceUrl) ->
    @_sourceEntriesByUrl[sourceUrl] ?=
      sourceUrl: sourceUrl
      objectUrl: null
      loadPromise: null
      abortController: null
      failed: false

  _loadSource: (sourceUrl, sourceEntry) ->
    return Promise.resolve sourceEntry.objectUrl if sourceEntry.objectUrl
    return sourceEntry.loadPromise if sourceEntry.loadPromise

    fetchOptions = _.extend {}, @fetchOptions

    if window.AbortController
      sourceEntry.abortController = new AbortController
      fetchOptions.signal = sourceEntry.abortController.signal

    sourceEntry.loadPromise = @_fetchSource sourceUrl, sourceEntry, fetchOptions

  _fetchSource: (sourceUrl, sourceEntry, fetchOptions) ->
    # Fetching into a blob keeps the original URL away from the video element, which prevents native referrer headers.
    try
      response = await fetch sourceUrl, fetchOptions
      throw new Error "Video request failed with status #{response.status}." unless response.ok

      videoBlob = await response.blob()
      videoObjectUrl = URL.createObjectURL videoBlob

      if @_destroyed
        URL.revokeObjectURL videoObjectUrl
        return

      sourceEntry.objectUrl = videoObjectUrl
      videoObjectUrl

    catch error
      # Destroying the manager aborts pending requests as part of normal cleanup.
      return if @_destroyed and error.name is 'AbortError'

      sourceEntry.failed = true
      @options.onLoadError? sourceUrl, error
      console.error "Could not load managed video.", error

  _assignVideoSource: (videoState, videoObjectUrl) ->
    video = videoState.video

    unless video.src is videoObjectUrl
      video.src = videoObjectUrl
      video.load()

    videoState.managedSourceAssigned = true
    videoState.objectUrl = videoObjectUrl

  _playVideoWhenReady: (videoState, requestId) ->
    return Promise.resolve() unless @_videoStateIsCurrent videoState, requestId

    video = videoState.video

    if video.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA
      return @_startVideoPlayback videoState, requestId

    # The media error event can fire before visibility processing reaches a native source.
    return Promise.resolve() if video.error

    # Wait until the newly assigned blob can play instead of producing a transient NotSupportedError.
    new Promise (resolve) =>
      videoState.readinessResolve = resolve

      videoState.canPlayHandler = =>
        @_clearVideoReadinessListeners videoState
        videoState.readinessResolve = null

        await @_startVideoPlayback videoState, requestId
        resolve()

      videoState.errorHandler = =>
        @_clearVideoReadinessListeners videoState
        videoState.readinessResolve = null
        resolve()

      video.addEventListener 'canplay', videoState.canPlayHandler
      video.addEventListener 'error', videoState.errorHandler

  _startVideoPlayback: (videoState, requestId) ->
    return unless @_videoStateIsCurrent videoState, requestId

    video = videoState.video

    if videoState.restart
      video.currentTime = 0
      videoState.restart = false

    try
      await video.play()

    catch error
      @_reportPlaybackError error

  _reportPlaybackError: (error) ->
    # Playback can be blocked, interrupted, or invalidated when its element is replaced.
    console.error error unless error.name in ['AbortError', 'NotAllowedError', 'NotSupportedError']

  _retryActiveVideos: ->
    for videoState in @_videoStates[..]
      unless videoState.video.isConnected
        @end videoState.video
        continue

      continue unless videoState.active and videoState.video.paused

      # Start a fresh request during the user gesture so browser playback authorization can apply.
      @_cancelVideoReadinessWait videoState
      videoState.requestId++
      @_requestVideoPlayback videoState, videoState.requestId

  _videoStateFor: (video) ->
    _.find @_videoStates, (videoState) => videoState.video is video

  _videoStateIsCurrent: (videoState, requestId) ->
    return false if @_destroyed
    return false unless videoState.active
    return false unless videoState.requestId is requestId
    return false unless videoState.video.isConnected

    @_videoStateFor(videoState.video) is videoState

  _cancelVideoReadinessWait: (videoState) ->
    @_clearVideoReadinessListeners videoState

    if videoState.readinessResolve
      readinessResolve = videoState.readinessResolve
      videoState.readinessResolve = null
      readinessResolve()

  _clearVideoReadinessListeners: (videoState) ->
    video = videoState.video

    if videoState.canPlayHandler
      video.removeEventListener 'canplay', videoState.canPlayHandler
      videoState.canPlayHandler = null

    if videoState.errorHandler
      video.removeEventListener 'error', videoState.errorHandler
      videoState.errorHandler = null
