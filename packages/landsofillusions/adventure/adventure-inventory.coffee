AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeInventory: ->
    # Create inventory.
    @inventory = new LOI.StateInstances
      state: =>
        # TODO: Implement inventory logic.
        {}
