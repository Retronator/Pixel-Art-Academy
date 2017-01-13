LOI = LandsOfIllusions

class LOI.Adventure.Script.Helpers extends LOI.Adventure.Script.Helpers
  # Activates an item and waits for the player to complete interacting with it.
  itemInteraction: (options) ->
    LOI.adventure.goToItem options.item

    # Wait until item has been active and deactivated again.
    itemWasActive = false

    Tracker.autorun (computation) =>
      activeItem = LOI.adventure.activeItem()

      if activeItem and not itemWasActive
        itemWasActive = true

      else if not activeItem and itemWasActive
        computation.stop()
        options.callback()
