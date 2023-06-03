AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.GoalContent extends LM.Content
  @goalClass = null # Override to set which goal this content represents.

  @displayName: -> @goalClass.displayName()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.GoalProgress
      content: @
      goalClass: @constructor.goalClass

  status: -> LM.Content.Status.Unlocked
