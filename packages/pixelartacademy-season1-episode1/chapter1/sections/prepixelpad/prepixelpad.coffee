LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PrePixelPad extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PrePixelPad'

  @scenes: -> [
    @Store
  ]

  @initialize()
  
  @started: -> true

  @finished: ->
    # This section is the same as waiting, but is active from
    # the start from chapter 1, so here we reuse Waiting's finished.
    C1.Waiting.finished()
