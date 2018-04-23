LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PixelBoy extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PixelBoy'

  @scenes: -> [
    @Store
  ]

  @initialize()

  @finished: ->
    # PixelBoy section is over when the user gets the PixelBoy.
    PAA.PixelBoy.state('inInventory') is true

  active: ->
    # Admission week starts when the character finished waiting for the acceptance letter.
    @requireFinishedSections C1.Waiting
