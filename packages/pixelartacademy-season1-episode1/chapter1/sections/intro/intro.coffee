LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Intro extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Intro'

  @scenes: -> [
    @Studio
  ]

  @initialize()

  @finished: ->
    # Intro section is over when the studio scene finishes.
    @Studio.state('finished') is true
