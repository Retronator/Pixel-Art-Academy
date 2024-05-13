AEc = Artificial.Echo
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Music.PlaybackChannel
  constructor: (@music) ->
    context = @music.audioManager.context()
    @gainNode = new GainNode context
    
    @stoppingTime = null
    @playing = new ReactiveField false
    
  destroy: ->
  
  ready: ->
  
  playing: ->
  
  startPlayback: (playback, fadeIn) ->
    unless @_output
      context = @music.audioManager.context()
      @_output = AEc.Node.Mixer.getOutputNodeForName 'in-game music', context
      @gainNode.connect @_output
    
    @playback = playback

    source = playback.getSourceNode()
    source.connect @gainNode
    
    playback.start()
    
    @resume fadeIn
    
    @playing true
  
  stopPlayback: (fadeOut) ->
    @pause fadeOut

    context = @music.audioManager.context()
    currentTime = context.currentTime
    @stoppingTime = currentTime + fadeOut
  
  pause: (fadeOut) ->
    context = @music.audioManager.context()
    currentTime = context.currentTime
    value = @gainNode.gain.value
    
    @gainNode.gain.cancelScheduledValues currentTime
    
    if fadeOut
      @gainNode.gain.setValueAtTime value, currentTime
      @gainNode.gain.linearRampToValueAtTime 0, currentTime + fadeOut
      
    else
      @gainNode.gain.setValueAtTime 0, currentTime
  
  resume: (fadeIn) ->
    context = @music.audioManager.context()
    currentTime = context.currentTime
    value = @gainNode.gain.value
    
    @gainNode.gain.cancelScheduledValues currentTime
    
    if fadeIn
      @gainNode.gain.setValueAtTime value, currentTime
      @gainNode.gain.linearRampToValueAtTime 1, currentTime + fadeIn
      
    else
      @gainNode.gain.setValueAtTime 1, currentTime
  
  update: (appTime) ->
    if @stoppingTime
      context = @music.audioManager.context()
      currentTime = context.currentTime
      
      if currentTime > @stoppingTime
        source = @playback.getSourceNode()
        source.disconnect @gainNode
    
        @playing false
        @stoppingTime = null
        
        @playback.stop()
        @playback = null
