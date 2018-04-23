LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

class C2.Intro extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Intro'

  @scenes: -> [
    @Caltrain
    @SecondStreet
    @Transbay
  ]

  @initialize()

  @finished: ->
    # Intro section is over when the player reaches Retronator HQ (or automatically if starting directly there). We
    # don't check for any entry to Retronator.HQ since other things get added to that namespace as soon as coming to
    # Chapter 2. So Intro will be active until reaching Cafe specifically (even if we teleport directly into the HQ
    # to some other location), but that's OK because to reach intro section you'd have to pass out through the Cafe.
    HQ.Cafe.state('visited') is true
