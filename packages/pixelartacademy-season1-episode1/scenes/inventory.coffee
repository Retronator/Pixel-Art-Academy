LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ

class E1.Inventory extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Inventory'

  @location: -> LOI.Adventure.Inventory

  @initialize()

  constructor: ->
    super

  # These are global things required in any character's inventory. 
  # Storyline inventory items are defined in the chapter they first appear. 
  things: -> [
    HQ.Items.OperatorLink
    LOI.Items.Sync
    LOI.Items.Time
  ]
