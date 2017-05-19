LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C3.Cafe extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Cafe'

  @location: -> HQ.Cafe

  @initialize()

  things: -> [
    SanFrancisco.Soma.Items.Map unless SanFrancisco.Soma.Items.Map.state 'inInventory'
  ]
