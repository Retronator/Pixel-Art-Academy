LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1

class E1.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Start'

  @finished: ->
    # Episode 1 is started when the character wakes up. Make sure we don't return undefined.
    E1.Start.WakeUp.state('finished') is true

  @scenes: -> [
    @WakeUp
  ]

  @initialize()
