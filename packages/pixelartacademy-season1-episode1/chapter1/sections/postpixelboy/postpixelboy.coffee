LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PostPixelBoy extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy'

  @scenes: -> [
    @Store
  ]

  @initialize()

  # This scene is present forever.
  @finished: -> false

  active: ->
    # This applies after the PixelBoy section.
    @requireFinishedSections C1.PixelBoy
