AEc = Artificial.Echo
AMe = Artificial.Melody
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Compositions.PixelArtFundamentals extends LM.Compositions.Composition
  constructor: ->
    super arguments...
    
    beatsPerMinute = 155
    beatDuration = 60 / beatsPerMinute
    barDuration = 4 * beatDuration
    
    # Create sections.
    
    sectionBarCounts =
      1:
        intro: 10
        loops:
          "2a": 16
          "2b": 16
          "3a": 16
          "3b": 16
          "3c": 16
          "3d": 16
      2:
        intro: 12
      3:
        intro: 4
        loops:
          "2": 8
          "3": 8
      4:
        intro: 5
        loops:
          "2": 12
          "3": 12
          "4": 12
          "5": 12
    
    createSection = (sectionBarCount, sectionGroupNumber, sectionSuffix) =>
      section = new AMe.Section @,
        duration: sectionBarCount * barDuration
        name: "#{sectionGroupNumber}-#{sectionSuffix}"
      
      section.events = [
        new AMe.Event.Player section,
          audioUrl: "/pixelartacademy/learnmode/compositions/pixelartfundamentals/#{sectionGroupNumber}-#{sectionSuffix}.mp3"
      ]
      
      @sections.push section
      
      section
    
    sections = {}
    
    for sectionGroupNumber, sectionGroupBarCounts of sectionBarCounts
      sections[sectionGroupNumber] =
        intro: createSection sectionGroupBarCounts.intro, sectionGroupNumber, "1"
        loops: for sectionSuffix, sectionBarCount of sectionGroupBarCounts.loops
          createSection sectionBarCount, sectionGroupNumber, sectionSuffix
      
    @initialSection = sections[1].intro

    # Create transitions.
        
    # Transition from intro to loops.
    for sectionGroupNumber, sectionGroup of sections
      for loopSection, loopSectionIndex in sectionGroup.loops
        sectionGroup.intro.transitions.push new AMe.Transition sectionGroup.intro,
          nextSection: loopSection
          # Prioritize the first loop section.
          priority: if loopSectionIndex then 0 else 1
          
    # Transition between loops.
    for sectionGroupNumber, sectionGroup of sections
      for loopSection, loopSectionIndex in sectionGroup.loops
        for otherLoopSection, otherLoopSectionIndex in sectionGroup.loops when loopSection isnt otherLoopSection
          loopSection.transitions.push new AMe.Transition loopSection,
            nextSection: otherLoopSection
            # Prioritize going to the next section and staying within the section group.
            priority: if otherLoopSectionIndex is loopSectionIndex + 1 then 1 else 0
          
    # Transition from 1 loops to 2, 3, and 4.
    for sectionGroupNumber in [2..4]
      for loopSection in sections[1].loops
        loopSection.transitions.push new AMe.Transition loopSection,
          nextSection: sections[sectionGroupNumber].intro

    # Transition from 2 to 3.
    sections[2].intro.transitions.push new AMe.Transition sections[2].intro,
      nextSection: sections[3].intro
      # Set a condition to trigger a condition-based decision.
      condition: => true
    
    # Transition from 2 to 4 when drawing.
    sections[2].intro.transitions.push new AMe.Transition sections[2].intro,
      nextSection: sections[4].intro
      # Go to section 4 a third of the time when drawing.
      condition: =>
        return unless @_drawingCondition()
        Math.random() < 0.33
    
    # Transition from 3 loops to 1 and 4.
    for sectionGroupNumber in [1, 4]
      for loopSection in sections[3].loops
        loopSection.transitions.push new AMe.Transition loopSection,
          nextSection: sections[sectionGroupNumber].intro
    
    # Transition from 4 loops to 1.
    for loopSection in sections[4].loops
      loopSection.transitions.push new AMe.Transition loopSection,
        nextSection: sections[1].intro

    # Force a transition out of the loops when not drawing.
    notDrawingCondition = => not @_drawingCondition()
        
    # Section 1 transitions to 2 when not drawing.
    for loopSection in sections[1].loops
      loopSection.transitions.push new AMe.Transition loopSection,
        nextSection: sections[2].intro
        condition: notDrawingCondition
  
    # Sections 3 and 4 transition to 1 when not drawing.
    for sectionGroupNumber in [3, 4]
      for loopSection in sections[sectionGroupNumber].loops
        loopSection.transitions.push new AMe.Transition loopSection,
          nextSection: sections[1].intro
          condition: notDrawingCondition

    # Force a transition to section 4 on cleanup lessons.
    cleanupLessonCondition = =>
      return unless drawingAppInfo = @_getDrawingAppInfo()
      
      activeAsset = drawingAppInfo.activeAsset
      linesCleanup = activeAsset instanceof PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineArtCleanup
      curvesCleanup = activeAsset instanceof PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup
      
      linesCleanup or curvesCleanup
  
    sectionsToTransitionTo4 = [
      sections[1].intro
      sections[1].loops...
      sections[2].intro
      sections[3].intro
      sections[3].loops...
    ]
    
    for section in sectionsToTransitionTo4
      section.transitions.push new AMe.Transition section,
        nextSection: sections[4].intro
        condition: cleanupLessonCondition
