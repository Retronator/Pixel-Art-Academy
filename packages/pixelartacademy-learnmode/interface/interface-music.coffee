AE = Artificial.Everywhere
AEc = Artificial.Echo
AMe = Artificial.Melody
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LM.Interface
  onCreated: ->
    super arguments...
    
    # Create the Learn Mode composition.
    @musicComposition = new AMe.Composition LOI.adventure.audioManager
    
    # Intro
    
    introSection = new AMe.Section @musicComposition,
      duration: 8
      
    introSection.events = [
      new AMe.Event.Player introSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/intro.mp3'
    ]
    
    @musicComposition.sections.push introSection
    @musicComposition.initialSection = introSection
    
    # Pixel pad
    
    homeScreenSection = new AMe.Section @musicComposition,
      duration: 40
    
    homeScreenSection.events = [
      new AMe.Event.Player homeScreenSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/homescreen.mp3'
    ]
    
    @musicComposition.sections.push homeScreenSection
    
    # Tutorial start
    
    tutorialStartSection = new AMe.Section @musicComposition,
      duration: 40
      
    tutorialStartSection.events = [
      new AMe.Event.Player tutorialStartSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/tutorial-start.mp3'
    ]
    
    @musicComposition.sections.push tutorialStartSection
    
    # Tutorial middle
    
    tutorialMiddleSection = new AMe.Section @musicComposition,
      duration: 40
      
    tutorialMiddleSection.events = [
      new AMe.Event.Player tutorialMiddleSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/tutorial-middle.mp3'
    ]
    
    @musicComposition.sections.push tutorialMiddleSection
    
    # Tutorial ending
    
    tutorialEndingSection = new AMe.Section @musicComposition,
      duration: 32
      
    tutorialEndingSection.events = [
      new AMe.Event.Player tutorialEndingSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/tutorial-ending.mp3'
    ]
    
    @musicComposition.sections.push tutorialEndingSection
    
    # Challenge start
    
    challengeStartSection = new AMe.Section @musicComposition,
      duration: 24
      
    challengeStartSection.events = [
      new AMe.Event.Player challengeStartSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/challenge-start.mp3'
    ]
    
    @musicComposition.sections.push challengeStartSection
    
    # Challenge ending
    
    challengeEndingSection = new AMe.Section @musicComposition,
      duration: 32
      
    challengeEndingSection.events = [
      new AMe.Event.Player challengeEndingSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/challenge-ending.mp3'
    ]
    
    @musicComposition.sections.push challengeEndingSection
    
    # Project
    
    projectSection = new AMe.Section @musicComposition,
      duration: 32
      
    projectSection.events = [
      new AMe.Event.Player projectSection,
        audioUrl: '/pixelartacademy/learnmode/interface/music/project.mp3'
    ]
    
    @musicComposition.sections.push projectSection
    
    # Create transitions.
    introSection.transitions.push new AMe.Transition introSection,
      nextSection: homeScreenSection
    
    challengeStartSection.transitions.push new AMe.Transition challengeStartSection,
      nextSection: challengeEndingSection
      
    transitioningSections =
      intro: introSection
      homeScreen: homeScreenSection
      tutorialStart: tutorialStartSection
      tutorialMiddle: tutorialMiddleSection
      tutorialEnding: tutorialEndingSection
      challengeStart: challengeStartSection
      challengeEnding: challengeEndingSection
      projectStart: projectSection
    
    for sectionNameA, sectionA of transitioningSections when sectionA and sectionA isnt challengeStartSection
      for sectionNameB, sectionB of transitioningSections when sectionB and sectionA isnt sectionB and @audio[sectionNameB]
        sectionA.transitions.push new AMe.Transition sectionA,
          nextSection: sectionB
          trigger: @audio[sectionNameB]
        
    # Play the composition when we are in play, unless the music system is playing a track or we're in the music app.
    @musicPlayback = new AMe.Playback LOI.adventure.audioManager, @musicComposition
    
    @dynamicSoundtrackPlaying = new ComputedField =>
      return unless @musicComposition.ready()
      return unless @musicPlayback.ready()
      return unless LOI.adventure.ready()
      return false unless LOI.adventure.currentLocationId() is LM.Locations.Play.id()
      return false if PAA.PixelPad.Systems.Music.state 'playing'
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless currentApp = pixelPad.os.currentApp()
      currentApp not instanceof PAA.PixelPad.Apps.Music

    @autorun (computation) =>
      dynamicSoundtrackPlaying = @dynamicSoundtrackPlaying()
      return unless dynamicSoundtrackPlaying?
      
      Tracker.nonreactive =>
        if dynamicSoundtrackPlaying
          if LOI.adventure.music.isPlayingPlayback @musicPlayback
            LOI.adventure.music.resume PAA.Music.FadeDurations.InGameMusicModeOffFadeIn
          
          else
            # Start the music after a short amount of silence.
            @_musicStartTimeout ?= Meteor.setTimeout =>
              LOI.adventure.music.startPlayback @musicPlayback
              @_musicStartTimeout = null
            ,
              PAA.Music.StartTimeoutDuration * 1000
          
        else if LOI.adventure.music.isPlayingPlayback @musicPlayback
          Meteor.clearTimeout @_musicStartTimeout
  
          if LOI.adventure.currentLocationId() is LM.Locations.Play.id()
            # While in play, we only need to pause the music so it can continue while being temporarily disabled.
            LOI.adventure.music.pause PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
            
          else
            # Outside of play we completely stop the music so it gets restarted the next time around.
            LOI.adventure.music.stopPlayback PAA.Music.FadeDurations.InGameMusicModeOffFadeOut
      
    # Trigger events.
    @autorun (computation) =>
      # When no app is opened, reset the music to default.
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      
      currentApp = pixelPad.os.currentApp()
      
      if currentApp instanceof PAA.PixelPad.Apps.HomeScreen
        @audio.homeScreen()
        return
      
      # React to drawing app changes.
      return unless currentApp instanceof PAA.PixelPad.Apps.Drawing
      drawing = currentApp
      
      # Wait until an asset is activated.
      return unless portfolio = drawing.portfolio()
      return unless activeAsset = portfolio.activeAsset()
      
      # See which section we're in and how far along in the group.
      activeSection = portfolio.activeSection()
      activeGroup = portfolio.activeGroup()
      activeAssets = activeGroup.assets()
      
      activeAssetIndex = _.findIndex activeAssets, (asset) => asset is activeAsset
      unitIndex = activeAssets.length - 1 - activeAssetIndex
      
      unitsCount = activeGroup.content?()?.progress.unitsCount() or 1
      groupProgress = if unitsCount > 1 then unitIndex / (unitsCount - 1) else 0
      
      switch activeSection.nameKey
        when PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
          if groupProgress < 1 / 3
            @audio.tutorialStart()
            
          else if groupProgress < 2 / 3
            @audio.tutorialMiddle()
            
          else
            @audio.tutorialEnding()
            
        when PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Challenges
          @audio.challengeStart()
          
        when PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Projects
          @audio.projectStart()
          
    # Control how to play the in-game music.
    @autorun (computation) =>
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
      
  onDestroyed: ->
    super arguments...
    
    @musicComposition?.destroy()
    @musicPlayback?.destroy()
