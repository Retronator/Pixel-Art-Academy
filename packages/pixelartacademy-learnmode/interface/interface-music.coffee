AE = Artificial.Everywhere
AEc = Artificial.Echo
AMe = Artificial.Melody
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LM.Interface
  onCreated: ->
    super arguments...
    
    @currentComposition = new ReactiveField null
    
    # Play the composition when we are in play, unless the music system is playing a track or we're in the music app.
    @currentMusicPlayback = new ComputedField =>
      @_currentMusicPlayback?.destroy()
      return unless currentComposition = @currentComposition()
      
      @_currentMusicPlayback = new AMe.Playback LOI.adventure.audioManager, currentComposition
      @_currentMusicPlayback
    
    @dynamicSoundtrackPlaying = new ComputedField =>
      return unless @currentComposition()?.ready()
      return unless @currentMusicPlayback()?.ready()
      return unless LOI.adventure.ready()
      return false unless LOI.adventure.currentLocationId() is LM.Locations.Play.id()
      return false if PAA.PixelPad.Systems.Music.state 'playing'
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless currentApp = pixelPad.os.currentApp()
      currentApp not instanceof PAA.PixelPad.Apps.Music

    @autorun (computation) =>
      dynamicSoundtrackPlaying = @dynamicSoundtrackPlaying()
      currentMusicPlayback = @currentMusicPlayback()
      return unless dynamicSoundtrackPlaying?
      
      Tracker.nonreactive =>
        if dynamicSoundtrackPlaying
          if LOI.adventure.music.isPlayingPlayback currentMusicPlayback
            LOI.adventure.music.resume PAA.Music.FadeDurations.InGameMusicModeOffFadeIn
          
          else
            # Start the music after a short amount of silence.
            @_musicStartTimeout ?= Meteor.setTimeout =>
              LOI.adventure.music.startPlayback currentMusicPlayback
              @_musicStartTimeout = null
            ,
              PAA.Music.StartTimeoutDuration * 1000
          
        else if LOI.adventure.music.isPlayingPlayback currentMusicPlayback
          Meteor.clearTimeout @_musicStartTimeout
  
          if LOI.adventure.currentLocationId() is LM.Locations.Play.id()
            # While in play, we only need to pause the music so it can continue while being temporarily disabled.
            LOI.adventure.music.pause PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
            
          else
            # Outside of play we completely stop the music so it gets restarted the next time around.
            LOI.adventure.music.stopPlayback PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
          
    # Control how to play the in-game music.
    @autorun (computation) =>
      # In the music effects settings menu, always play the music in location.
      if LOI.adventure.menu.visible() and LOI.adventure.menu.items.inMusicEffectsSettings()
        @audio.inGameMusicInLocation true
        return
      
      pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      inGameMusicMode = pixelPad?.os.currentApp()?.inGameMusicMode?()
      
      unless inGameMusicMode is @constructor.InGameMusicMode.Off
        switch LOI.settings.audio.inGameMusicOutput.value()
          when LOI.Settings.Audio.InGameMusicOutput.InLocation then inGameMusicMode = @constructor.InGameMusicMode.InLocation
          when LOI.Settings.Audio.InGameMusicOutput.Direct then inGameMusicMode = @constructor.InGameMusicMode.Direct
      
      @audio.inGameMusicInLocation inGameMusicMode is @constructor.InGameMusicMode.InLocation unless inGameMusicMode is @constructor.InGameMusicMode.Off
      
    # Pause music when apps require it to be off.
    @inGameMusicModeOff = new ComputedField =>
      pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      pixelPad?.os.currentApp()?.inGameMusicMode?() is @constructor.InGameMusicMode.Off
      
    @autorun (computation) =>
      if @inGameMusicModeOff()
        LOI.adventure.music.pause PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
        
      else
        LOI.adventure.music.resume PAA.Music.FadeDurations.InGameMusicModeOffFadeIn
        
    # Pause music in the menus, except on the audio screen.
    @autorun (computation) =>
      if @audioOffInMenus()
        LOI.adventure.music.pause PAA.Music.FadeDurations.MenuFadeOut
      
      else
        LOI.adventure.music.resume PAA.Music.FadeDurations.MenuFadeIn
        
    # Start the first song.
    @_startComposition LM.Compositions.ElementsOfArt
      
  onDestroyed: ->
    super arguments...
    
    @_currentComposition?.destroy()
    @_currentMusicPlayback?.destroy()
    
  _startComposition: (compositionClass) ->
    @_currentComposition?.destroy()
    @_currentComposition = new compositionClass LOI.adventure.audioManager
    @currentComposition @_currentComposition
