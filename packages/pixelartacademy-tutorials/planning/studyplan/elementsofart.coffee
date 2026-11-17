AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.Tutorials.Planning.StudyPlan.InterfaceMarking

class PAA.Tutorials.Planning.StudyPlan.ElementsOfArt
  class @ElementsOfArtAddedWithoutConnections extends PAA.Tutorials.Planning.StudyPlan.ExpansionPointInstruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.ElementsOfArt.ElementsOfArtAddedWithoutConnections"
    
    @message: -> """
      Your learning journey revolves around the seven elements of art.
      Completing each one leads to specialized side quests that apply that element to pixel art.
    """
    
    @delayDuration: -> 2
    
    @priority: -> 1
    
    @initialize()

    activeConditions: ->
      # Don't show if other dialogs are open.
      return if @modalWindowDisplayed()
      
      # Show when Elements of art goal has been added but no other connections go out of it.
      return unless goalData = StudyPlan.getGoalData PAA.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt
      return if goalData.connections?.length
      
      # Wait until the expansion point has been added.
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
            x: -60
            y: -50
            width: 200
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
                  x: 10, y: -20
                ]
                x: 5, y: -15
              ]
            text: _.extend {}, textBase,
              position:
                x: 30, y: -25, origin: Markup.TextOriginPosition.MiddleLeft
              value: "You can now plan ahead\nand add side goals"
              align: Markup.TextAlign.Left
          ,
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 27, y: -25
              ,
                bezierControlPoints: [
                  x: 20, y: -25
                ,
                  x: -15, y: -25
                ]
                x: -25, y: -15
              ]
          ]
      ]
