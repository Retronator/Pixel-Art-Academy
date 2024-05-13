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
  
  title: -> @_title
  
  artist: -> @_artist
  
  ready: ->
    @canPlayThrough()
    
  currentTime: -> @_audioElement.currentTime
  
  setCurrentTime: (value) -> @_audioElement.currentTime = value
  
  ended: -> @_audioElement.ended
  
  getSourceNode: ->
    return @_output if @_output
    
    @_context = @audioManager.context()
    @_output = new MediaElementAudioSourceNode @_context,
      mediaElement: @_audioElement

  start: ->
    @_audioElement.play()
    
  stop: ->
    @_audioElement.pause()
