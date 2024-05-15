AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Music
  constructor: (@audioManager) ->
    @playbackChanged = new AB.Event
    
    @currentPlaybackChannel = new @constructor.PlaybackChannel @
    @nextPlaybackChannel = new @constructor.PlaybackChannel @
    
    @enabled = new AE.LiveComputedField =>
      # Music can't be enabled unless the audio manager context is running.
      return false unless @audioManager.running()
      
      # Music should be enabled in the audio settings screen (to respond quickly to changes of music volume).
      return true if LOI.adventure.inAudioMenu()
      
      # Music is enabled if music volume is not zero.
      LOI.settings.audio.musicVolume.value() > 0
      
  destroy: ->
    @currentPlaybackChannel.destroy()
    @nextPlaybackChannel.destroy()
    
    @enabled.stop()

  startPlayback: (playback, fadeIn, fadeOutExisting) ->
    Tracker.nonreactive =>
      if @currentPlaybackChannel.active()
        @currentPlaybackChannel.stopPlayback fadeOutExisting ? fadeIn
        @nextPlaybackChannel.startPlayback playback, fadeIn
        
      else
        @currentPlaybackChannel.startPlayback playback, fadeIn
        @playbackChanged()
  
  stopPlayback: (fadeOut) ->
    Tracker.nonreactive =>
      @currentPlaybackChannel.stopPlayback fadeOut
      @nextPlaybackChannel.stopPlayback fadeOut
  
  pause: (fadeOut) ->
    Tracker.nonreactive =>
      @currentPlaybackChannel.pause fadeOut
      @nextPlaybackChannel.pause fadeOut
  
  resume: (fadeIn) ->
    Tracker.nonreactive =>
      @currentPlaybackChannel.resume fadeIn
      @nextPlaybackChannel.resume fadeIn
  
  isPlayingPlayback: (playback) ->
    @currentPlaybackChannel.playback() is playback or @nextPlaybackChannel.playback() is playback
  
  update: (appTime) ->
    @currentPlaybackChannel.update appTime
    @nextPlaybackChannel.update appTime
  
    # Switch channels when the current one stops playing.
    if @nextPlaybackChannel.active() and not @currentPlaybackChannel.active()
      [@currentPlaybackChannel, @nextPlaybackChannel] = [@nextPlaybackChannel, @currentPlaybackChannel]
      @playbackChanged()
