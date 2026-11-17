AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.Tutorials.Planning.StudyPlan.InterfaceMarking

class PAA.Tutorials.Planning.StudyPlan.PixelArtFundamentals
  class @ChessNotStarted extends PAA.Tutorials.Planning.StudyPlan.Instruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.PixelArtFundamentals.ChessNotStarted"
    
    @message: -> """
      Some goals can be reached from different directions. Each entry task requires different interests.
    """
    
    @delayDuration: -> 2
    
    @priority: -> 1
    
    @initialize()

    activeConditions: ->
      # Don't show if progression is open.
      return unless studyPlan = @getStudyPlan()
      return if studyPlan.showProgression()
      
      # Show when Chess goal has been and until it becomes available.
      return unless StudyPlan.hasGoal PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess
      return if PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess.available()
      
      true
      
    completedConditions: ->
      if studyPlan = @getStudyPlan()
        if highlightedTaskId = studyPlan.highlightedTaskId()
          if highlightedTaskId is PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess.TwoDimensional.id()
            PAA.Tutorials.Planning.Instructions.StudyPlan.state 'instructions.chessNotStarted.hovered2D', true
          
          if highlightedTaskId is PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess.ThreeDimensional.id()
            PAA.Tutorials.Planning.Instructions.StudyPlan.state 'instructions.chessNotStarted.hovered3D', true
      
      PAA.Tutorials.Planning.Instructions.StudyPlan.state('instructions.chessNotStarted.hovered2D') and PAA.Tutorials.Planning.Instructions.StudyPlan.state('instructions.chessNotStarted.hovered3D')
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: "[data-goalid='#{PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Chess.id()}']"
          trackTarget: true
          bounds:
            x: -60
            y: -75
            width: 210
            height: 150
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: -10, y: -45
              ,
                bezierControlPoints: [
                  x: -10, y: -35
                ,
                  x: 0, y: -25
                ]
                x: 14, y: -22
              ]
            text: _.extend {}, textBase,
              position:
                x: -10, y: -50, origin: Markup.TextOriginPosition.BottomCenter
              value: "See which interests\nare needed to start the\nChess project in 2D"
              align: Markup.TextAlign.Center
          ,
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 100, y: 35
              ,
                bezierControlPoints: [
                  x: 85, y: 20
                ,
                  x: 78, y: 41
                ]
                x: 63, y: 26
              ]
            text: _.extend {}, textBase,
              position:
                x: 100, y: 40, origin: Markup.TextOriginPosition.TopCenter
              value: "Hover to see which\ninterests are required for\nstarting Chess in 3D"
              align: Markup.TextAlign.Center
          ]
      ]
