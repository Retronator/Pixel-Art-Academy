AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.Tutorials.Planning.StudyPlan.InterfaceMarking

class PAA.Tutorials.Planning.StudyPlan.ExpansionPoints
  class @Instruction extends PAA.Tutorials.Planning.StudyPlan.ExpansionPointInstruction
    @delayDuration: -> @defaultDelayDuration
    
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayStates.Hidden
      
    activeConditions: ->
      # Show until add new goal is selected.
      return if @getStudyPlan()?.addGoalOptions()
      
      # Show after Snake goal is completed.
      return unless LM.Intro.Tutorial.Goals.Snake.completed()
  
      true
  
  class @ForwardShortTerm extends @Instruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.ExpansionPoints.ForwardShortTerm"
    
    @initialize()
    
    activeConditions: ->
      return unless super arguments...
      
      @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Forward, StudyPlan.GoalTypes.ShortTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.forward.short-term"
          trackTarget: true
          bounds:
            x: 0
            y: -50
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 60, y: -12
              ,
                bezierControlPoints: [
                  x: 60, y: -2
                ,
                  x: 40, y: 3
                ]
                x: 28, y: 3
              ]
            text: _.extend {}, textBase,
              position:
                x: 60, y: -17, origin: Markup.TextOriginPosition.BottomCenter
              value: "Add a new goal\nto continue to"
              align: Markup.TextAlign.Center
          ]
      ]
  
  class @SidewaysShortTerm extends @Instruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.ExpansionPoints.SidewaysShortTerm"
    
    @initialize()
    
    activeConditions: ->
      return unless super arguments...
    
      @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Sideways, StudyPlan.GoalTypes.ShortTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.sideways.short-term"
          trackTarget: true
          bounds:
            x: -60
            y: -50
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: -15, y: -30
              ,
                bezierControlPoints: [
                  x: -15, y: -25
                ,
                  x: -10, y: -17
                ]
                x: -5, y: -12
              ]
            text: _.extend {}, textBase,
              position:
                x: -15, y: -35, origin: Markup.TextOriginPosition.BottomCenter
              value: "You can continue to\na new goal in parallel"
              align: Markup.TextAlign.Center
          ]
      ]
      
  class @ForwardMidTerm extends @Instruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.ExpansionPoints.ForwardMidTerm"
    
    @initialize()
    
    activeConditions: ->
      return unless super arguments...
    
      @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Forward, StudyPlan.GoalTypes.MidTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.forward.mid-term"
          trackTarget: true
          bounds:
            x: 0
            y: -50
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 60, y: -12
              ,
                bezierControlPoints: [
                  x: 60, y: -2
                ,
                  x: 40, y: 3
                ]
                x: 28, y: 3
              ]
            text: _.extend {}, textBase,
              position:
                x: 60, y: -17, origin: Markup.TextOriginPosition.BottomCenter
              value: "See what goals you can\ncontinue to after"
              align: Markup.TextAlign.Center
          ]
      ]

  class @SidewaysMidTerm extends @Instruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.ExpansionPoints.SidewaysMidTerm"
    
    @initialize()
    
    activeConditions: ->
      return unless super arguments...
    
      @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Sideways, StudyPlan.GoalTypes.MidTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.sideways.mid-term"
          trackTarget: true
          bounds:
            x: 0
            y: -70
            width: 130
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 27, y: -25
              ,
                bezierControlPoints: [
                  x: 20, y: -25
                ,
                  x: 15, y: -20
                ]
                x: 10, y: -15
              ]
            text: _.extend {}, textBase,
              position:
                x: 30, y: -25, origin: Markup.TextOriginPosition.MiddleLeft
              value: "You can plan ahead and\nadd a side goal in parallel"
              align: Markup.TextAlign.Left
          ]
      ]
