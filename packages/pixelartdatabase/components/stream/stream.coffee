AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Components.Stream extends AM.Component
  @register 'PixelArtDatabase.Components.Stream'

  constructor: (captionComponentClassOrOptions = {}) ->
    super arguments...

    if _.isFunction captionComponentClassOrOptions
      @options =
        captionComponentClass: captionComponentClassOrOptions

    else
      @options = captionComponentClassOrOptions

  onCreated: ->
    super arguments...

    @videoManager = new PADB.Components.VideoManager
      onLoadError: @options.onVideoLoadError

    @displayedArtworks = new ComputedField =>
      artworks = @data()
      return unless artworks

      # Add extra data to artworks.
      for artwork in artworks
        displayedArtwork =
          artwork: artwork

        if artwork.image
          displayedArtwork.imageUrl ?= artwork.image.url or artwork.image.src

          if artwork.image instanceof HTMLImageElement
            displayedArtwork.imageElement = artwork.image

        if artwork.representations
          for representation in artwork.representations
            if representation.type is PADB.Artwork.RepresentationTypes.Image
              displayedArtwork.imageUrl ?= representation.url

            if representation.type is PADB.Artwork.RepresentationTypes.Video
              displayedArtwork.videoUrl ?= representation.url

        displayedArtwork

  onRendered: ->
    super arguments...
    
    if @options.scrollParentSelector
      @_$scrollParent = $(@options.scrollParentSelector)

    else
      @_$scrollParent = $(window)

    # Start/stop videos when the artworks come 1 viewport away from being visible.
    @artworkVisibilityTracker = new AM.ElementVisibilityTracker @,
      elements: => @$('.artwork-area')
      scrollParent: @_$scrollParent
      viewportHeightDistance: 1
      elementIdentityAndData: (artworkAreaElement) =>
        $artworkArea = $(artworkAreaElement)
        displayedArtwork = Blaze.getData artworkAreaElement
        artworkKey = displayedArtwork?.artwork?._id or displayedArtwork?.imageUrl
        video = $artworkArea.find('video')[0]
        videoUrl = displayedArtwork?.videoUrl

        identity: [artworkKey, video, videoUrl]
        data:
          video: video
          videoUrl: videoUrl

      visible: (visibilityInfo) =>
        {video, videoUrl} = visibilityInfo.data
        return unless video

        sourceUrl = videoUrl if @options.loadVideosWithoutReferrer
        @videoManager.play video, sourceUrl, restart: true

      hidden: (visibilityInfo) =>
        video = visibilityInfo.data.video
        @videoManager.pause video if video

      destroyed: (visibilityInfo) =>
        video = visibilityInfo.data.video
        @videoManager.end video if video

    @artworkVisibilityTracker.start()

    # Update artwork visibility on resizes and artwork updates.
    @autorun (computation) =>
      AM.Window.clientBounds()
      @displayedArtworks()

      # Wait till the new artwork areas get rendered.
      Tracker.afterFlush =>
        return unless @isRendered()

        @artworkVisibilityTracker.refresh()

  onDestroyed: ->
    super arguments...

    @artworkVisibilityTracker?.destroy()
    @videoManager.destroy()
