PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Content.Goals extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Goals'

  @displayName: -> "Study goals"

  @contents: -> [
    @ShapeLanguage
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      requiredUnits: "goals"
      totalUnits: "tasks"
      totalRecursive: true
  
  status: -> @constructor.Status.Unlocked

  class @ShapeLanguage extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Goals.ShapeLanguage'
    @goalClass = LM.Design.Fundamentals.Goals.ShapeLanguage
    @initialize()
  
  class @Invasion extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.Goals.Invasion'
    @goalClass = LM.Design.Fundamentals.Goals.Invasion
    @initialize()
