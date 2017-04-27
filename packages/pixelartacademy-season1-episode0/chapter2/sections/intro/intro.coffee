LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

class C2.Intro extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Intro'

  @scenes: -> [
    @Caltrain
    @SecondStreet
  ]

  @initialize()

  @finished: ->
    # Intro section is over when the player reaches Retronator HQ.
    HQ.Cafe.state('visited') is true
