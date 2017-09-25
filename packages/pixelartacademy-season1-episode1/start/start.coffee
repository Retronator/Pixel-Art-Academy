LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1

class E1.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Start'

  @finished: ->
    # TODO: Episode 1 is started after the initial conversation with the character.
    false

  @scenes: -> [
    @WakeUp
  ]

  @initialize()
