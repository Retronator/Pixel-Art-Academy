AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  @debugActiveItem = false

  _initializeActiveItem: ->
    # Similar to location, create the active item.
    @activeItemId = new ReactiveField null

    @activeItem = new ComputedField =>
      # Wait until location is ready and all things at location have loaded.
      currentLocation = @currentLocation()
      return unless currentLocation?.ready()

      activeItemId = @activeItemId()

      # Did the item even change?
      return @_activeItem if activeItemId is @_activeItem?.constructor.id()

      console.log "Active item ID changed to", activeItemId if LOI.debug or LOI.Adventure.debugActiveItem

      console.log "Do we have an active item to deactivate?", @_activeItem if LOI.debug or LOI.Adventure.debugActiveItem
      # Active item is not the same, so deactivate the current one if we have one.
      @_activeItem?.deactivate()

      # Do we even have the new item or did we switch to no item?
      if activeItemId
        # We do have an item, so find it in the inventory or at the location.
        @_activeItem = @getCurrentThing activeItemId

        console.log "Did we find the new active item?", @_activeItem if LOI.debug or LOI.Adventure.debugActiveItem

        if @_activeItem
          @_activeItem.activate()

        else
          # We can't use an item we don't have or see.
          @activeItemId null

      else
        # No more object
        @_activeItem = null

      @_activeItem
    ,
      # Make sure to keep this computed field running.
      true

  deactivateActiveItem: ->
    @activeItemId null
