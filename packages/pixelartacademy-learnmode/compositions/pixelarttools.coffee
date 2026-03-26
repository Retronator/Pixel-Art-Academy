AEc = Artificial.Echo
AMe = Artificial.Melody
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Compositions.PixelArtTools extends LM.Compositions.Composition
  constructor: ->
    super arguments...
    
    # Intro
    
    introSection = new AMe.Section @,
      duration: 8
      
    introSection.events = [
      new AMe.Event.Player introSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/intro.mp3'
    ]
    
    @sections.push introSection
    @initialSection = introSection
    
    # Home screen
    
    homeScreenSection = new AMe.Section @,
      duration: 40
    
    homeScreenSection.events = [
      new AMe.Event.Player homeScreenSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/homescreen.mp3'
    ]
    
    @sections.push homeScreenSection
    
    # Tutorial start
    
    tutorialStartSection = new AMe.Section @,
      duration: 40
      
    tutorialStartSection.events = [
      new AMe.Event.Player tutorialStartSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/tutorial-start.mp3'
    ]
    
    @sections.push tutorialStartSection
    
    # Tutorial middle
    
    tutorialMiddleSection = new AMe.Section @,
      duration: 40
      
    tutorialMiddleSection.events = [
      new AMe.Event.Player tutorialMiddleSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/tutorial-middle.mp3'
    ]
    
    @sections.push tutorialMiddleSection
    
    # Tutorial ending
    
    tutorialEndingSection = new AMe.Section @,
      duration: 32
      
    tutorialEndingSection.events = [
      new AMe.Event.Player tutorialEndingSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/tutorial-ending.mp3'
    ]
    
    @sections.push tutorialEndingSection
    
    # Challenge start
    
    challengeStartSection = new AMe.Section @,
      duration: 24
      
    challengeStartSection.events = [
      new AMe.Event.Player challengeStartSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/challenge-start.mp3'
    ]
    
    @sections.push challengeStartSection
    
    # Challenge ending
    
    challengeEndingSection = new AMe.Section @,
      duration: 32
      
    challengeEndingSection.events = [
      new AMe.Event.Player challengeEndingSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/challenge-ending.mp3'
    ]
    
    @sections.push challengeEndingSection
    
    # Project
    
    projectSection = new AMe.Section @,
      duration: 32
      
    projectSection.events = [
      new AMe.Event.Player projectSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/pixelarttools/project.mp3'
    ]
    
    @sections.push projectSection
    
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
      project: projectSection
      
    transitionConditions =
      homeScreen: @_homeScreenTransitionCondition
      tutorialStart: @_tutorialStartTransitionCondition
      tutorialMiddle: @_tutorialMiddleTransitionCondition
      tutorialEnding: @_tutorialEndingTransitionCondition
      challengeStart: =>
        return unless drawingAppInfo = @_getDrawingAppInfo()
        drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Challenges
      project: =>
        return unless drawingAppInfo = @_getDrawingAppInfo()
        drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Projects
        
    for sectionNameA, sectionA of transitioningSections when sectionA isnt challengeStartSection
      for sectionNameB, sectionB of transitioningSections when transitionConditions[sectionNameB]
        sectionA.transitions.push new AMe.Transition sectionA,
          nextSection: sectionB
          condition: transitionConditions[sectionNameB]
