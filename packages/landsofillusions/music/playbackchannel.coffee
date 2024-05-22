AEc = Artificial.Echo
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Music.PlaybackChannel
  constructor: (@music) ->
    @_ready = false
    @_onReadyStartPlayback = null
    @_onReadyPaused = false
    
    @_contextAutorun = Tracker.autorun (computation) =>
      return unless context = @music.audioManager.context()
      computation.stop()
      
      @gainNode = new GainNode context
      @gainNode.gain.value = 0
      
      @_ready = true
    
      if @_onReadyStartPlayback
        @_onReadyStartPlayback()
    
    @_pausingTime = null
    @_stoppingTime = null
    
    @playback = new ReactiveField null
    
  destroy: ->
    @_contextAutorun.stop()
  
  active: -> @playback()?
  
  startPlayback: (playback, fadeIn = 0) ->
    action = =>
      context = @music.audioManager.context()

      unless @_output
        @_output = AEc.Node.Mixer.getOutputNodeForName 'in-game music', context
        @gainNode.connect @_output
      
      @playback playback
  
      playback.connect @gainNode
      
      @gainNode.gain.cancelScheduledValues context.currentTime
      @gainNode.gain.value = 0
      @_stoppingTime = null
      
      playback.start()
      
      if @_onReadyPaused
        @_onReadyPaused = false
        playback.pause?()
        
      else
        @resume fadeIn
    
    if @_ready
      action()
      
    else
      @_onReadyStartPlayback = action
  
  stopPlayback: (fadeOut = 0) ->
    unless @_ready
      @_onReadyStartPlayback = null
      return
      
    return unless @playback()
    return if @_stoppingTime
    
    @pause fadeOut

    context = @music.audioManager.context()
    currentTime = context.currentTime
    @_stoppingTime = currentTime + fadeOut
  
  pause: (fadeOut = 0) ->
    unless @_ready
      @_onReadyPaused = true
      return
      
    return unless @playback()
    return if @_stoppingTime

    context = @music.audioManager.context()
    currentTime = context.currentTime
    value = @gainNode.gain.value
    
    @gainNode.gain.cancelScheduledValues currentTime
    
    @_pausingTime = currentTime + fadeOut
    
    if fadeOut
      @gainNode.gain.setValueAtTime value, currentTime
      @gainNode.gain.linearRampToValueAtTime 0, @_pausingTime
      
    else
      @gainNode.gain.setValueAtTime 0, currentTime
  
  resume: (fadeIn = 0) ->
    unless @_ready
      @_onReadyPaused = false
      return
      
    playback = @playback()
    return unless playback
    return if @_stoppingTime
    
    playback.resume?()
    
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
    return unless @_ready
    
    if @_pausingTime or @_stoppingTime
      context = @music.audioManager.context()
      currentTime = context.currentTime
      
      if @_pausingTime and currentTime > @_pausingTime
        playback = @playback()
        playback.pause?()
        
        @_pausingTime= null
      
      if @_stoppingTime and currentTime > @_stoppingTime
        playback = @playback()
        playback.stop()
        playback.disconnect()
    
        @_stoppingTime = null
        
        @playback null
