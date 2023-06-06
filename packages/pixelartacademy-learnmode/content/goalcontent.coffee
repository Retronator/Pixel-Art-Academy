AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.GoalContent extends LM.Content
  @goalClass = null # Override to set which goal this content represents.

  @type: -> 'GoalContent'

  @displayName: -> @goalClass.displayName()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.GoalProgress
      content: @
      goalClass: @constructor.goalClass
      totalUnits: "tasks"

  status: -> LM.Content.Status.Unlocked
