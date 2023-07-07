LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PixelPad extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PixelPad'

  @scenes: -> [
    @Store
  ]

  @initialize()
  
  @started: ->
    # Admission week starts when the character finished waiting for the acceptance letter.
    @requireFinishedSections C1.Waiting

  @finished: ->
    # PixelPad section is over when the user gets the PixelPad.
    PAA.PixelPad.state('inInventory') is true
