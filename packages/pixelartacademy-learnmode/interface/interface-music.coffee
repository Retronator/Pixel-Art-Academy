AE = Artificial.Everywhere
AEc = Artificial.Echo
AMe = Artificial.Melody
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LM.Interface
  onCreated: ->
    super arguments...
    
    @_previousDynamicSoundtrackComposition = null
    @currentDynamicSoundtrackComposition = new ReactiveField null
    
    # Play the composition when we are in play, unless the music system is playing a track or we're in the music app.
    @_previousDynamicSoundtrackPlayback = null
    @currentDynamicSoundtrackPlayback = new ReactiveField null
    
    @dynamicSoundtrackPlaying = new ComputedField =>
      return unless LOI.adventure.ready()
      return false unless LOI.adventure.currentLocationId() is LM.Locations.Play.id()
      return false if PAA.PixelPad.Systems.Music.state 'playing'
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless currentApp = pixelPad.os.currentApp()
      currentApp not instanceof PAA.PixelPad.Apps.Music

    @autorun (computation) =>
      dynamicSoundtrackPlaying = @dynamicSoundtrackPlaying()
      currentDynamicSoundtrackComposition = @currentDynamicSoundtrackComposition()
      return unless dynamicSoundtrackPlaying?
      
      Tracker.nonreactive =>
        currentDynamicSoundtrackPlayback = @currentDynamicSoundtrackPlayback()

        if dynamicSoundtrackPlaying
          # Check if the right composition is already playing.
          if @_previousDynamicSoundtrackPlayback?.composition is currentDynamicSoundtrackComposition and LOI.adventure.music.isPlayingPlayback @_previousDynamicSoundtrackPlayback
            # It is, we simply need to resume it.
            LOI.adventure.music.resume PAA.Music.FadeDurations.InGameMusicModeOffFadeIn
          
          else
            startPlaybackWaitDuration = PAA.Music.StartTimeoutDuration
            
            # It is not. If we have a different composition playing, we need to fade it out.
            if @_previousDynamicSoundtrackPlayback
              LOI.adventure.music.stopPlayback PAA.Music.FadeDurations.DynamicSoundtrackSongChangeFadeOut if LOI.adventure.music.isPlayingPlayback @_previousDynamicSoundtrackPlayback
              startPlaybackWaitDuration += PAA.Music.FadeDurations.DynamicSoundtrackSongChangeFadeOut
              
              # Destroy the playback and composition after the fade out and some grace time.
              @_destroyCurrentDynamicSoundtrack PAA.Music.FadeDurations.DynamicSoundtrackSongChangeFadeOut
            
            # Create new playback.
            @_previousDynamicSoundtrackComposition = currentDynamicSoundtrackComposition
            @_previousDynamicSoundtrackPlayback = new AMe.Playback LOI.adventure.audioManager, currentDynamicSoundtrackComposition
            @currentDynamicSoundtrackPlayback @_previousDynamicSoundtrackPlayback
            
            startMusicWhenReady = =>
              # If the composition playback is not yet ready, retry in 0.1s.
              unless @_previousDynamicSoundtrackComposition.ready() and @_previousDynamicSoundtrackPlayback.ready()
                @_musicStartTimeout = Meteor.setTimeout startMusicWhenReady, 100
                return
                
              # The song is now ready. play it!
              LOI.adventure.music.startPlayback @_previousDynamicSoundtrackPlayback
              @_musicStartTimeout = null
            
            # Start the music after a short amount of silence.
            Meteor.clearTimeout @_musicStartTimeout
            @_musicStartTimeout = Meteor.setTimeout startMusicWhenReady, startPlaybackWaitDuration * 1000
          
        else if LOI.adventure.music.isPlayingPlayback currentDynamicSoundtrackPlayback
          Meteor.clearTimeout @_musicStartTimeout
  
          if LOI.adventure.currentLocationId() is LM.Locations.Play.id()
            # While in play, we only need to pause the music so it can continue while being temporarily disabled.
            LOI.adventure.music.pause PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
            
          else
            # Outside of play we completely stop the music so it gets restarted the next time around.
            LOI.adventure.music.stopPlayback PAA.Music.FadeDurations.InGameMusicModeOffFadeOut

            # Destroy the playback and composition after the fade out and some grace time.
            @_destroyCurrentDynamicSoundtrack PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
    
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
        
    # Start the correct dynamic soundtrack composition.
    @drawingAppDeterminedCompositionClass = new ComputedField (computation) =>
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless currentApp = pixelPad.os.currentApp()
      return unless currentApp instanceof PAA.PixelPad.Apps.Drawing
      
      # In the drawing app, see which episode the content is coming from.
      drawing = currentApp
      
      # Wait until an asset is activated.
      return unless portfolio = drawing.portfolio()
      return unless portfolio.activeAsset()
      
      activeGroup = portfolio.activeGroup()
      activeThing = activeGroup.thing
      return unless course = activeThing?.content().course
      
      if course instanceof LM.Intro.Tutorial.Content.Course
        # Intro
        LM.Compositions.PixelArtTools
        
      else if course instanceof LM.PixelArtFundamentals.Fundamentals.Content.Course
        # Pixel art fundamentals
        if activeThing instanceof PAA.Tutorials.Drawing.ElementsOfArt
          LM.Compositions.ElementsOfArt
        
        else if activeThing instanceof PAA.Tutorials.Drawing.Simplification
          LM.Compositions.ElementsOfArt
        
        else if activeThing instanceof PAA.Tutorials.Drawing.PixelArtFundamentals
          LM.Compositions.PixelArtFundamentals
        
      else if course instanceof LM.Design.Fundamentals.Content.Course
        # Design fundamentals
        if activeThing instanceof PAA.Tutorials.Drawing.Design
          LM.Compositions.ElementsOfArt
      
        else if activeThing instanceof PAA.Pico8.Cartridges.Invasion.Project
          LM.Compositions.PixelArtFundamentals

    previouslyAvailableCompositionClasses = []
  
    @autorun (computation) =>
      drawingAppDeterminedCompositionClass = @drawingAppDeterminedCompositionClass()
      currentChapters = LOI.adventure.currentChapters()
      currentLocationId = LOI.adventure.currentLocationId()
      
      Tracker.nonreactive =>
        # Outside of play, there is no dynamic composition.
        unless currentLocationId is LM.Locations.Play.id()
          @currentDynamicSoundtrackComposition null
          previouslyAvailableCompositionClasses = []
          return
          
        currentDynamicSoundtrackComposition = @currentDynamicSoundtrackComposition()
        
        if drawingAppDeterminedCompositionClass
          # When the drawing app is able to determine the composition class, we use that.
          desiredCompositionClass = drawingAppDeterminedCompositionClass
          
        else
          # Otherwise we leave the composition playing unless no composition is
          # playing, or if a new composition is available that wasn't previously.
          availableCourses = _.flatten (chapter.courses for chapter in currentChapters)
  
          availableCompositionClasses = []
          
          for course in availableCourses
            if course instanceof LM.Intro.Tutorial.Content.Course
              availableCompositionClasses.push LM.Compositions.PixelArtTools
              
            else if course instanceof LM.PixelArtFundamentals.Fundamentals.Content.Course
              availableCompositionClasses.push LM.Compositions.ElementsOfArt
          
              if PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
                availableCompositionClasses.push LM.Compositions.PixelArtFundamentals
          
          for compositionClass in availableCompositionClasses when compositionClass not in previouslyAvailableCompositionClasses or not currentDynamicSoundtrackComposition
            desiredCompositionClass = compositionClass
          
          previouslyAvailableCompositionClasses = availableCompositionClasses
          
          return unless desiredCompositionClass
        
        return if currentDynamicSoundtrackComposition instanceof desiredCompositionClass
      
        @currentDynamicSoundtrackComposition new desiredCompositionClass LOI.adventure.audioManager
      
  onDestroyed: ->
    super arguments...
    
    @_currentDynamicSoundtrackComposition?.destroy()
    @_currentDynamicSoundtrackPlayback?.destroy()

  _destroyCurrentDynamicSoundtrack: (fadeOutDuration) ->
    # Destroy the playback and composition after the fade out and some grace time.
    previousDynamicSoundtrackComposition = @_previousDynamicSoundtrackComposition
    previousDynamicSoundtrackPlayback = @_previousDynamicSoundtrackPlayback
    
    return unless @_previousDynamicSoundtrackComposition

    @_previousDynamicSoundtrackComposition = null
    @_previousDynamicSoundtrackPlayback = null
    
    Meteor.setTimeout =>
      previousDynamicSoundtrackPlayback.destroy()
      previousDynamicSoundtrackComposition.destroy()
    ,
      fadeOutDuration * 1100
