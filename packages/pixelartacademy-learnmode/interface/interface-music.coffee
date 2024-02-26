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
    @musicComposition = new AMe.Composition @audioManager
    
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
        
    # Play the composition every time we enter play.
    @musicPlayback = new AMe.Playback @audioManager, @musicComposition, 'in-game music'
    
    @inGameMusicPlaying = new ComputedField =>
      return unless @musicComposition.ready()
      return unless @musicPlayback.ready()
      return unless LOI.adventure.ready()
      LOI.adventure.currentLocationId() is LM.Locations.Play.id()

    @autorun (computation) =>
      if @inGameMusicPlaying()
        # Start the music after a short amount of silence.
        @_musicStartTimeout ?= Meteor.setTimeout =>
          @musicPlayback.start()
          @_musicStartTimeout = null
        ,
          2000
        
      else
        @musicPlayback.stop()
      
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
      value = pixelPad?.os.currentApp()?.inGameMusicMode?()
      
      unless value is @constructor.InGameMusicMode.Off
        switch LOI.settings.audio.inGameMusicOutput.value()
          when LOI.Settings.Audio.InGameMusicOutput.InLocation then value = @constructor.InGameMusicMode.InLocation
          when LOI.Settings.Audio.InGameMusicOutput.Direct then value = @constructor.InGameMusicMode.Direct
      
      # We need separate booleans for whether the music is playing instead of an enum and how it's playing so that the effects don't change
      @audio.inGameMusic value isnt @constructor.InGameMusicMode.Off
      @audio.inGameMusicInLocation value is @constructor.InGameMusicMode.InLocation unless value is @constructor.InGameMusicMode.Off
      
    # Play the dynamic soundtrack when no custom music is playing.
    @autorun (computation) =>
      @audio.dynamicSoundtrack true

  onDestroyed: ->
    super arguments...
    
    @musicComposition?.destroy()
    @musicPlayback?.destroy()
