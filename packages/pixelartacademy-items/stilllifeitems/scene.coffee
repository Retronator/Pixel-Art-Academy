LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Scene extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Scene'
  @location: -> LOI.Adventure.Inventory

  @initialize()

  things: ->
    items = PAA.Items.StillLifeItems.items()
    return [] unless items.length

    _.flatten [
      # Include the cumulative thing that appears in the inventory.
      PAA.Items.StillLifeItems

      # Include all actual items.
      for item in items when itemClass = _.thingClass item.type
        itemClass.getCopyForId item.id
    ]
