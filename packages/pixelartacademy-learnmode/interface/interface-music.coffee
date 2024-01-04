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
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-intro.mp3'
      ]
    
    @musicComposition.sections.push introSection
    @musicComposition.initialSection = introSection
    
    # Pixel pad
    
    homeScreenSection = new AMe.Section @musicComposition,
      duration: 40
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-tutorial-start.mp3'
          time: 8
      ]
      
    @musicComposition.sections.push homeScreenSection
    
    # Tutorial start
    
    tutorialStartSection = new AMe.Section @musicComposition,
      duration: 40
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/drums-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-tutorial-start.mp3'
          time: 8
      ]
    
    @musicComposition.sections.push tutorialStartSection
    
    # Tutorial middle
    
    tutorialMiddleSection = new AMe.Section @musicComposition,
      duration: 40
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/drums-tutorial-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-tutorial-middle.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-tutorial-middle.mp3'
          time: 8
      ]
    
    @musicComposition.sections.push tutorialMiddleSection
    
    # Tutorial ending
    
    tutorialEndingSection = new AMe.Section @musicComposition,
      duration: 32
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-tutorial-ending.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/chords-tutorial-ending.mp3'
          time: 16
          volume: 0.5
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/hihats-tutorial-ending.mp3'
          time: 8
          volume: 0.2
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/drums-tutorial-ending.mp3'
          time: 8
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-tutorial-ending.mp3'
          volume: 0.5
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-tutorial-ending.mp3'
          time: 4
      ]
    
    @musicComposition.sections.push tutorialEndingSection
    
    # Challenge start
    
    challengeStartSection = new AMe.Section @musicComposition,
      duration: 24
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-challenge-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/chords-challenge-start.mp3'
          volume: 0.2
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/hihats-challenge-start.mp3'
          volume: 0.2
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/drums-challenge-start.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-challenge-start.mp3'
          time: 8
          volume: 0.5
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-challenge-start.mp3'
      ]
    
    @musicComposition.sections.push challengeStartSection
    
    # Challenge ending
    
    challengeEndingSection = new AMe.Section @musicComposition,
      duration: 32
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-challenge-ending.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/hihats-challenge-ending.mp3'
          volume: 0.2
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/drums-challenge-ending.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-challenge-ending.mp3'
          volume: 0.5
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-challenge-ending.mp3'
      ]
    
    @musicComposition.sections.push challengeEndingSection
    
    # Project
    
    projectSection = new AMe.Section @musicComposition,
      duration: 32
      events: [
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/bass-project.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/drums-project.mp3'
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/melody-project.mp3'
          time: 6
      ,
        new AMe.Event.Player @audioManager,
          audioUrl: '/pixelartacademy/learnmode/interface/music/pads-project.mp3'
          time: 14
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
    
    for sectionNameA, sectionA of transitioningSections when sectionA
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
        Meteor.clearTimeout @_musicStopTimeout
        Tracker.nonreactive => @musicPlayback.start()
        
      else
        # Stop the music after a fade out.
        @_musicStopTimeout ?= Meteor.setTimeout =>
          @musicPlayback.stop()
          @_musicStopTimeout = null
        ,
          2000
      
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
          
    # Control if the in-game music is played through the location or directly.
    @autorun (computation) =>
      # By default we switch between the modes depending on whether we're in the drawing editor.
      @audio.inGameMusicInLocation PAA.PixelPad.Apps.Drawing.Editor.getEditor()?.active()

  onDestroyed: ->
    super arguments...
    
    @musicComposition?.destroy()
    @musicPlayback?.destroy()
