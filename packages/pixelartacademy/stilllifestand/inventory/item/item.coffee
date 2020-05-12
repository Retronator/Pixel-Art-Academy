AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Inventory.Item extends AM.Component
  @id: -> 'PixelArtAcademy.StillLifeStand.Inventory.Item'
  @register @id()

  onCreated: ->
    super arguments...

    @_item = null

    @item = new ComputedField =>
      @_item?.destroy()

      itemData = @data()
      itemClass = _.thingClass itemData.type

      if itemData.type is itemData.id
        # If no special ID is given, we have a unique item.
        @_item = new itemClass

      else
        # Otherwise we need to get the specific copy for the ID.
        @_item = itemClass.getCopyForId itemData.id

      @_item
