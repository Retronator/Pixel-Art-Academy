AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Music
  constructor: (@audioManager) ->
    @playbackChanged = new AB.Event
    
    @currentPlaybackChannel = new ReactiveField null
    @nextPlaybackChannel = new ReactiveField null
    
    Tracker.nonreactive =>
      @_createChannelsAutorun = Tracker.autorun (computation) =>
        return unless @audioManager.context()
        computation.stop()
        
        @currentPlaybackChannel new @constructor.PlaybackChannel @
        @nextPlaybackChannel new @constructor.PlaybackChannel @
    
    @enabled = new AE.LiveComputedField =>
      # Music can't be enabled unless the audio manager context is running.
      return false unless @audioManager.running()
      
      # Music should be enabled in the audio settings screen (to respond quickly to changes of music volume).
      return true if LOI.adventure.inAudioMenu()
      
      # Music is enabled if music volume is not zero.
      LOI.settings.audio.musicVolume.value() > 0
      
  destroy: ->
    @_createChannelsAutorun.stop()
    
    @currentPlaybackChannel().destroy()
    @nextPlaybackChannel().destroy()
    
    @enabled.stop()
  
  ready: -> @audioManager.context() and @currentPlaybackChannel().ready()

  startPlayback: (playback, fadeIn) ->
    currentPlaybackChannel = @currentPlaybackChannel()
    nextPlaybackChannel = @nextPlaybackChannel()
    
    if currentPlaybackChannel.playing()
      currentPlaybackChannel.stopPlayback fadeIn
      nextPlaybackChannel.startPlayback playback, fadeIn
      
    else
      currentPlaybackChannel.startPlayback playback, fadeIn
      @playbackChanged()
  
  stopPlayback: (fadeOut) ->
    currentPlaybackChannel = @currentPlaybackChannel()
    nextPlaybackChannel = @nextPlaybackChannel()
    
    promises = [
      currentPlaybackChannel.stopPlayback fadeOut
      nextPlaybackChannel.stopPlayback fadeOut
    ]
    
    await Promise.all promises
  
  pause: (fadeOut) ->
    @currentPlaybackChannel().pause fadeOut
    @nextPlaybackChannel().pause fadeOut
  
  resume: (fadeIn) ->
    @currentPlaybackChannel().pause fadeIn
    @nextPlaybackChannel().pause fadeIn
  
  isPlayingPlayback: (playback) ->
    currentPlaybackChannel = @currentPlaybackChannel()
    nextPlaybackChannel = @nextPlaybackChannel()
    
    currentPlaybackChannel.playback is playback or nextPlaybackChannel.playback is playback
  
  update: (appTime) ->
    return unless currentPlaybackChannel = @currentPlaybackChannel()
    return unless nextPlaybackChannel = @nextPlaybackChannel()
  
    # Switch channels when the current one stops playing.
    if nextPlaybackChannel.playing() and not currentPlaybackChannel.playing()
      @currentPlaybackChannel nextPlaybackChannel
      @nextPlaybackChannel currentPlaybackChannel
      @playbackChanged()
