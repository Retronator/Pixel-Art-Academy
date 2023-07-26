AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.FutureContent extends LM.Content
  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ManualProgress
      content: @
  
  status: -> LM.Content.Status.Unavailable
