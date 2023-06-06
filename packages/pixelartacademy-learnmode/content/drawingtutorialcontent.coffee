AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.DrawingTutorialContent extends LM.Content
  @tutorialClass = null # Override to set which tutorial this content represents.

  @type: -> 'DrawingTutorialContent'

  @displayName: -> @tutorialClass.fullName()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ManualProgress
      content: @
      units: "steps"

      completed: => @constructor.tutorialClass.completed()

      unitsCount: => @constructor.tutorialClass.assetsCount()
      completedUnitsCount: => @constructor.tutorialClass.completedAssetsCount()
      completedRatio: => @constructor.tutorialClass.completedRatio()

      requiredUnitsCount: => @constructor.tutorialClass.requiredAssetsCount()
      requiredCompletedUnitsCount: => @constructor.tutorialClass.requiredCompletedAssetsCount()
      requiredCompletedRatio: => @constructor.tutorialClass.requiredCompletedRatio()

  status: -> LM.Content.Status.Unlocked
