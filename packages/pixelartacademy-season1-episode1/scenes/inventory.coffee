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

  things: ->
    items = [
      HQ.Items.OperatorLink
      LOI.Items.Sync
      LOI.Items.Time
    ]
    
    obtainableItems = [
      PAA.PixelBoy
      SanFrancisco.Soma.Items.Map
    ]

    for itemClass in obtainableItems
      hasItem = itemClass.state 'inInventory'
      items.push itemClass if hasItem

    items
