LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class E1.Store extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Store'

  @location: -> HQ.Store

  @initialize()

  things: -> [
    HQ.Store.Shelf.Pico8
    HQ.Store.Shelf.Pixel
  ]

  removeThings: -> [
    HQ.Store.Shelf.Game
    HQ.Store.Shelf.Upgrades
  ]
