LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Waiting extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Waiting'

  @scenes: -> [
  ]

  @initialize()

  @finished: ->
    # Waiting section is over when character gets accepted to admission week.
    C1.readOnlyState('application')?.accepted is true

  active: ->
    # Waiting section starts when the character has applied to the program.
    return false unless C1.state('application')?.applied is true

    # Make sure the section stops when it's finished (default).
    super