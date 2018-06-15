LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

class C2.Registration extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Registration'

  @scenes: -> [
    @Cafe
  ]

  @initialize()
  
  @started: -> true

  @finished: ->
    # Registration section is over when the player gets the keycard.
    HQ.Items.Keycard.state('inInventory') is true
