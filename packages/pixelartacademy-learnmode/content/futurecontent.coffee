AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.FutureContent extends LM.Content
  @tags: -> [LM.Content.Tags.Future]

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ManualProgress
      content: @
      completed: => false
  
  status: -> LM.Content.Status.Unavailable
