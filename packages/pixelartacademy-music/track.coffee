LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Music.Track
  constructor: (@audioManager, @_title, @_artist, @url, @gain = 1) ->
    @_audioElement = new Audio
    
    @canPlayThrough = new ReactiveField false
    
    @_audioElement.oncanplaythrough = =>
      @canPlayThrough true
  
    # HACK: Load through a request so that it works on desktop, otherwise no valid source is found.
    request = new XMLHttpRequest
    request.open 'GET', @url, true
    request.responseType = 'arraybuffer'

    request.onload = =>
      # Make sure the URL points to an audio MIME type.
      contentType = request.getResponseHeader 'content-type'
      return unless _.startsWith contentType, 'audio'
      
      blob = new Blob [request.response], type: contentType
      @_audioElement.src = URL.createObjectURL blob
      
    request.send()
    
  destroy: ->
    @stop()
    @_source?.disconnect()
    @_output?.disconnect()
    @_source = null
    @_output = null
  
  title: -> @_title
  
  artist: -> @_artist
  
  ready: ->
    @canPlayThrough()
    
  currentTime: -> @_audioElement.currentTime
  
  setCurrentTime: (value) -> @_audioElement.currentTime = value
  
  ended: -> @_audioElement.ended
  
  _getSourceNode: ->
    return @_output if @_output
    
    @_context = @audioManager.context()
    @_source = new MediaElementAudioSourceNode @_context, mediaElement: @_audioElement
    @_output = new GainNode @_context, gain: @gain
    @_source.connect @_output
    
    @_output
    
  connect: (node) ->
    sourceNode = @_getSourceNode()
    sourceNode.connect node
    
  disconnect: ->
    @_output?.disconnect()

  start: ->
    @_audioElement.play()
    
  stop: ->
    @_audioElement.pause()
    
  pause: ->
    @_audioElement.pause()

  resume: ->
    @_audioElement.play()
