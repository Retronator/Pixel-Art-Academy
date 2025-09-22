AEc = Artificial.Echo
AMe = Artificial.Melody
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Compositions.ElementsOfArt extends LM.Compositions.Composition
  constructor: ->
    super arguments...
    
    # Home screen
    
    homeScreenSection = new AMe.Section @,
      name: 'Home screen'
      duration: 9.6
    
    homeScreenSection.events = [
      new AMe.Event.Player homeScreenSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/homescreen.mp3'
    ]
    
    @sections.push homeScreenSection
    @initialSection = homeScreenSection
    
    # Tutorial intro
    
    tutorialIntroSection = new AMe.Section @,
      name: 'Tutorial intro'
      duration: 9.6
      
    tutorialIntroSection.events = [
      new AMe.Event.Player tutorialIntroSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/tutorial-intro.mp3'
    ]
    
    @sections.push tutorialIntroSection
    
    # Tutorial start
    
    tutorialStartSection = new AMe.Section @,
      name: 'Tutorial start'
      duration: 19.2
    
    tutorialStartSection.events = [
      new AMe.Event.Player tutorialStartSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/tutorial-start.mp3'
    ]
    
    @sections.push tutorialStartSection
    
    # Tutorial middle
    
    tutorialMiddleSection = new AMe.Section @,
      name: 'Tutorial middle'
      duration: 38.4
      
    tutorialMiddleSection.events = [
      new AMe.Event.Player tutorialMiddleSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/tutorial-middle.mp3'
    ]
    
    @sections.push tutorialMiddleSection
    
    # Tutorial ending
    
    tutorialEnding1Section = new AMe.Section @,
      name: 'Tutorial ending 1'
      duration: 19.2
      
    tutorialEnding1Section.events = [
      new AMe.Event.Player tutorialEnding1Section,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/tutorial-ending-1.mp3'
    ]
    
    @sections.push tutorialEnding1Section

    tutorialEnding2Section = new AMe.Section @,
      name: 'Tutorial ending 2'
      duration: 19.2
      
    tutorialEnding2Section.events = [
      new AMe.Event.Player tutorialEnding2Section,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/tutorial-ending-2.mp3'
    ]
    
    @sections.push tutorialEnding2Section
    
    # Drawing start
    
    drawingStartSection = new AMe.Section @,
      name: 'Drawing start'
      duration: 19.2
    
    drawingStartSection.events = [
      new AMe.Event.Player drawingStartSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/drawing-start.mp3'
    ]
    
    @sections.push drawingStartSection
    
    # Drawing middle
    
    drawingMiddleSection = new AMe.Section @,
      name: 'Drawing middle'
      duration: 38.4
    
    drawingMiddleSection.events = [
      new AMe.Event.Player drawingMiddleSection,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/drawing-middle.mp3'
    ]
    
    @sections.push drawingMiddleSection
    
    # Drawing ending
    
    drawingEnding1Section = new AMe.Section @,
      name: 'Drawing ending 1'
      duration: 38.4
    
    drawingEnding1Section.events = [
      new AMe.Event.Player drawingEnding1Section,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/drawing-ending-1.mp3'
    ]
    
    @sections.push drawingEnding1Section
    
    drawingEnding2Section = new AMe.Section @,
      name: 'Drawing ending 2'
      duration: 19.2
    
    drawingEnding2Section.events = [
      new AMe.Event.Player drawingEnding2Section,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/drawing-ending-2.mp3'
    ]
    
    @sections.push drawingEnding2Section
    
    drawingEnding3Section = new AMe.Section @,
      name: 'Drawing ending 3'
      duration: 38.4
    
    drawingEnding3Section.events = [
      new AMe.Event.Player drawingEnding3Section,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/drawing-ending-3.mp3'
    ]
    
    @sections.push drawingEnding3Section
    
    drawingEnding4Section = new AMe.Section @,
      name: 'Drawing ending 4'
      duration: 19.2
    
    drawingEnding4Section.events = [
      new AMe.Event.Player drawingEnding4Section,
        audioUrl: '/pixelartacademy/learnmode/compositions/elementsofart/drawing-ending-4.mp3'
    ]
    
    @sections.push drawingEnding4Section
    
    # Create transitions.
    
    # Transition to home screen.
    # any tutorial -> home screen

    tutorialSections = [
      tutorialIntroSection
      tutorialStartSection
      tutorialMiddleSection
      tutorialEnding1Section
      tutorialEnding2Section
    ]
    
    for tutorialSection in tutorialSections
      tutorialSection.transitions.push new AMe.Transition tutorialSection,
        nextSection: homeScreenSection
        condition: @_homeScreenTransitionCondition
    
    # Transition to tutorials.
    # home screen -> tutorial intro
    # tutorial intro -> tutorial start
    # tutorial start -> tutorial middle
    # tutorial middle -> tutorial ending 1
    # tutorial ending 1,2 -> tutorial start
    # tutorial ending 1,2 -> tutorial middle
    
    homeScreenSection.transitions.push new AMe.Transition homeScreenSection,
      nextSection: tutorialIntroSection
      condition: => @_getCurrentApp() instanceof PAA.PixelPad.Apps.Drawing
    
    tutorialIntroSection.transitions.push new AMe.Transition tutorialIntroSection,
      nextSection: tutorialStartSection
      condition: =>
        return unless drawingAppInfo = @_getDrawingAppInfo()
        drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
    
    tutorialStartSection.transitions.push new AMe.Transition tutorialStartSection,
      nextSection: tutorialMiddleSection
      condition: =>
        return unless drawingAppInfo = @_getDrawingAppInfo()
        return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        drawingAppInfo.groupProgress >= 1 / 3
    
    tutorialMiddleSection.transitions.push new AMe.Transition tutorialMiddleSection,
      nextSection: tutorialEnding1Section
      condition: =>
        return unless drawingAppInfo = @_getDrawingAppInfo()
        return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        drawingAppInfo.groupProgress >= 2 / 3
    
    for tutorialSection in [tutorialEnding1Section, tutorialEnding2Section]
      tutorialSection.transitions.push new AMe.Transition tutorialSection,
        nextSection: tutorialMiddleSection
        condition: =>
          return unless drawingAppInfo = @_getDrawingAppInfo()
          return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
          1 / 3 <= drawingAppInfo.groupProgress < 2 / 3
    
    for tutorialSection in [tutorialEnding1Section, tutorialEnding2Section]
      tutorialSection.transitions.push new AMe.Transition tutorialSection,
        nextSection: tutorialStartSection
        condition: =>
          return unless drawingAppInfo = @_getDrawingAppInfo()
          return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
          drawingAppInfo.groupProgress < 1 / 3
    
    # Auto-advance the tutorial sections.
    # tutorial ending 1 -> tutorial ending 2
    # tutorial ending 2 -> tutorial ending 1
    
    tutorialEnding1Section.transitions.push new AMe.Transition tutorialEnding1Section,
      nextSection: tutorialEnding2Section
    
    tutorialEnding2Section.transitions.push new AMe.Transition tutorialEnding2Section,
      nextSection: tutorialEnding1Section
    
    # Transition to and from drawing sections.
    # Tutorial start -> drawing start (when < 1 / 3)
    # Tutorial middle -> drawing middle (when < 2 / 3)
    # Tutorial ending 2 -> drawing ending 1
    # Drawing start -> tutorial start
    # Drawing middle -> tutorial middle
    # Drawing ending 1 -> tutorial ending 1
    # Drawing ending 2 -> tutorial ending 1
    # Drawing ending 3 -> tutorial ending 1
    # Drawing ending 4 -> drawing intro
    
    drawingSections = [
      drawingStartSection
      drawingMiddleSection
      drawingEnding1Section
      drawingEnding2Section
      drawingEnding3Section
      drawingEnding4Section
    ]
    
    mustExitDrawingSection = new ReactiveField false
    
    @_mustExitDrawingSectionAutorun = Tracker.autorun =>
      return unless dynamicSoundtrackPlayback = LOI.adventure.interface.currentDynamicSoundtrackPlayback()
      return unless dynamicSoundtrackPlayback.composition is @
      
      currentSection = dynamicSoundtrackPlayback.currentSection()
      
      if currentSection in drawingSections
        mustExitDrawingSection true unless @_drawingCondition()
      
      else
        mustExitDrawingSection false
      
    tutorialStartSection.transitions.push new AMe.Transition tutorialStartSection,
      nextSection: drawingStartSection
      condition: =>
        return unless @_drawingCondition()
        return unless drawingAppInfo = @_getDrawingAppInfo()
        return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        drawingAppInfo.groupProgress < 1 / 3
    
    tutorialMiddleSection.transitions.push new AMe.Transition tutorialMiddleSection,
      nextSection: drawingMiddleSection
      condition: =>
        return unless @_drawingCondition()
        return unless drawingAppInfo = @_getDrawingAppInfo()
        return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        drawingAppInfo.groupProgress < 2 / 3
    
    tutorialEnding2Section.transitions.push new AMe.Transition tutorialEnding2Section,
      nextSection: drawingEnding1Section
      condition: => @_drawingCondition()
    
    stopDrawingCondition = => not @_drawingCondition() or mustExitDrawingSection()
    
    drawingStartSection.transitions.push new AMe.Transition drawingStartSection,
      nextSection: tutorialStartSection
      condition: stopDrawingCondition
    
    drawingMiddleSection.transitions.push new AMe.Transition drawingMiddleSection,
      nextSection: tutorialMiddleSection
      condition: stopDrawingCondition
    
    for drawingEndingSection in [drawingEnding1Section, drawingEnding2Section, drawingEnding3Section]
      drawingEndingSection.transitions.push new AMe.Transition drawingEndingSection,
        nextSection: tutorialEnding1Section
        condition: stopDrawingCondition
      
    drawingEnding4Section.transitions.push new AMe.Transition drawingEnding4Section,
      nextSection: tutorialIntroSection
      condition: stopDrawingCondition

    # Auto-advance the drawing sections until drawing has been exited.
    # drawing-start -> drawing-middle (when >= 1 / 3)
    # drawing-middle -> drawing-start
    # drawing-middle -> drawing-ending (when >= 2 / 3)
    # drawing-ending-1 -> drawing-ending-2
    # drawing-ending-2 -> drawing-ending-3
    # drawing-ending-3 -> drawing-ending-4
    # drawing-ending-4 -> drawing-start
    
    continueDrawingCondition = => not mustExitDrawingSection()
    
    drawingStartSection.transitions.push new AMe.Transition drawingStartSection,
      nextSection: drawingMiddleSection
      condition: =>
        return unless continueDrawingCondition()
        return unless drawingAppInfo = @_getDrawingAppInfo()
        return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        drawingAppInfo.groupProgress >= 1 / 3
        
    drawingMiddleSection.transitions.push new AMe.Transition drawingMiddleSection,
      nextSection: drawingStartSection
      
    drawingMiddleSection.transitions.push new AMe.Transition drawingMiddleSection,
      nextSection: drawingEnding1Section
      condition: =>
        return unless continueDrawingCondition()
        return unless drawingAppInfo = @_getDrawingAppInfo()
        return unless drawingAppInfo.activeSection.nameKey is PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        drawingAppInfo.groupProgress >= 2 / 3
    
    drawingEnding1Section.transitions.push new AMe.Transition drawingEnding1Section,
      nextSection: drawingEnding2Section
      condition: continueDrawingCondition
    
    drawingEnding2Section.transitions.push new AMe.Transition drawingEnding2Section,
      nextSection: drawingEnding3Section
      condition: continueDrawingCondition
    
    drawingEnding3Section.transitions.push new AMe.Transition drawingEnding3Section,
      nextSection: drawingEnding4Section
      condition: continueDrawingCondition
    
    drawingEnding4Section.transitions.push new AMe.Transition drawingEnding4Section,
      nextSection: drawingStartSection
      condition: continueDrawingCondition

    # Temporarily reuse the song also for Pixel Art Fundamentals challenges and projects.
    # home screen -> tutorial intro
    # tutorial intro -> tutorial start
    # tutorial start -> tutorial middle
    # tutorial middle -> tutorial ending 1
    # tutorial ending 1 -> tutorial ending 2
    # tutorial ending 2 -> tutorial start
    # drawing-start -> drawing-middle
    # drawing-middle -> tutorial-middle
    
    portfolioNotInTutorialsOrOtherAppsCondition = =>
      if drawingAppInfo = @_getDrawingAppInfo()
        drawingAppInfo.activeSection.nameKey isnt PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
        
      else
        return unless currentApp = @_getCurrentApp()
        currentApp not instanceof PAA.PixelPad.Apps.HomeScreen
    
    homeScreenSection.transitions.push new AMe.Transition homeScreenSection,
      nextSection: tutorialIntroSection
      condition: portfolioNotInTutorialsOrOtherAppsCondition
      
    tutorialIntroSection.transitions.push new AMe.Transition tutorialIntroSection,
      nextSection: tutorialStartSection
      condition: portfolioNotInTutorialsOrOtherAppsCondition
    
    tutorialStartSection.transitions.push new AMe.Transition tutorialStartSection,
      nextSection: tutorialMiddleSection
      condition: portfolioNotInTutorialsOrOtherAppsCondition
    
    tutorialMiddleSection.transitions.push new AMe.Transition tutorialMiddleSection,
      nextSection: tutorialEnding1Section
      condition: portfolioNotInTutorialsOrOtherAppsCondition
    
    tutorialEnding1Section.transitions.push new AMe.Transition tutorialEnding1Section,
      nextSection: tutorialEnding2Section
      condition: portfolioNotInTutorialsOrOtherAppsCondition
    
    tutorialEnding2Section.transitions.push new AMe.Transition tutorialEnding2Section,
      nextSection: tutorialStartSection
      condition: =>
        return unless portfolioNotInTutorialsOrOtherAppsCondition()
        not @_drawingCondition()
      
    continueDrawingNotInTutorialsCondition = =>
      return unless continueDrawingCondition()
      return unless drawingAppInfo = @_getDrawingAppInfo()
      drawingAppInfo.activeSection.nameKey isnt PAA.PixelPad.Apps.Drawing.Portfolio.Sections.Tutorials
      
    drawingStartSection.transitions.push new AMe.Transition drawingStartSection,
      nextSection: drawingMiddleSection
      condition: continueDrawingNotInTutorialsCondition
      
    drawingMiddleSection.transitions.push new AMe.Transition drawingMiddleSection,
      nextSection: tutorialMiddleSection
      condition: continueDrawingNotInTutorialsCondition
      
  destroy: ->
    super arguments...
    
    @_mustExitDrawingSectionAutorun.stop()
