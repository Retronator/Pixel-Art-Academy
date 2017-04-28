LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C2.Store extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Store'

  @location: -> HQ.Store

  @initialize()

  things: -> [
    HQ.Items.ShoppingCart unless HQ.Items.ShoppingCart.state 'inInventory'
  ]
