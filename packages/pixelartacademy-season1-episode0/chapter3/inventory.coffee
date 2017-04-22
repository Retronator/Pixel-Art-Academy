LOI = LandsOfIllusions
PAA = PixelArtAcademy
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ

class C3.Inventory extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Inventory'

  @location: -> LOI.Adventure.Inventory

  @initialize()

  things: -> [
      C3.Items.OperatorLink
    ]
