AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.AppContent extends LM.Content
  @appClass = null # Override to set which goal this content represents.

  @type: -> 'AppContent'

  @displayName: -> @appClass.fullName()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ManualProgress
      content: @
      completed: => true
      completedRatio: => 1

  status: -> if PAA.PixelBoy.Apps.LearnMode.isAppUnlocked @constructor.appClass.id() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
