AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.AppContent extends LM.Content
  @appClass = null # Override to set which app this content represents.

  @type: -> 'AppContent'

  @displayName: -> @appClass.fullName()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ManualProgress
      content: @
      completed: => true
