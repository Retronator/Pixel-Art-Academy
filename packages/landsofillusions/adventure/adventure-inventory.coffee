AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeInventory: ->
    @inventoryLocation = new LOI.Adventure.Inventory()

    @currentInventory = new ComputedField =>
      new LOI.Adventure.Situation
        location: @inventoryLocation
        timelineId: @currentTimelineId()
