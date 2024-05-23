LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Music.Track
  constructor: (@audioManager, @_title, @_artist, @url) ->
    @_audioElement = new Audio @url
    
    @canPlayThrough = new ReactiveField false
    
    @_audioElement.oncanplaythrough = =>
      @canPlayThrough true
  
  destroy: ->
    @stop()
    @_output?.disconnect()
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
    @_output = new MediaElementAudioSourceNode @_context,
      mediaElement: @_audioElement
      
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
