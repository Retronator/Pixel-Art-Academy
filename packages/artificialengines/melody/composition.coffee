AMe = Artificial.Melody

class AMe.Composition
  constructor: (@audioManager) ->
    @sections = []
    @initialSection = null
    
    @_loadingAudioBufferUrls = []
    @_audioBuffers = {}
    @_loadingDependency = new Tracker.Dependency
    
    @_contextAutorun = Tracker.autorun (computation) =>
      return unless @_context = @audioManager.context()
      computation.stop()
      
      @_requestAudioBuffer url for url in @_loadingAudioBufferUrls
  
  destroy: ->
    @_contextAutorun?.stop()
  
  ready: ->
    return unless @audioManager.context()
    
    @_loadingDependency.depend()
    @_loadingAudioBufferUrls.length is 0
    
  loadAudioBuffer: (url) ->
    return if url in @_loadingAudioBufferUrls
    @_loadingAudioBufferUrls.push url
    
    return unless @_context
    
    @_requestAudioBuffer url
  
  _requestAudioBuffer: (url) ->
    console.log "Requesting audio buffer", url if AMe.debug

    request = new XMLHttpRequest
    request.open 'GET', url, true
    request.responseType = 'arraybuffer'

    request.onload = =>
      # Make sure the URL points to an audio MIME type.
      contentType = request.getResponseHeader 'content-type'
      return unless _.startsWith contentType, 'audio'

      @_context.decodeAudioData request.response, (buffer) =>
        @_audioBuffers[url] = buffer
        _.pull @_loadingAudioBufferUrls, url
        @_loadingDependency.changed()
        
        console.log "Loaded audio buffer", url, buffer if AMe.debug
    
    request.send()
  
  getAudioBuffer: (url) ->
    @_audioBuffers[url]
