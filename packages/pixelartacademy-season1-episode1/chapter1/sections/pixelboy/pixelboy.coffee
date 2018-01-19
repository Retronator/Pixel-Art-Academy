LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.PixelBoy extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PixelBoy'

  @scenes: -> [
  ]

  @initialize()

  active: ->
    # Admission week starts when the character finished waiting for the acceptance letter.
    @requireFinishedSections C1.Waiting

  @finished: ->
    false
