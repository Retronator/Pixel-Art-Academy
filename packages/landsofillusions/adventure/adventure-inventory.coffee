AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeInventory: ->
    # Create inventory.
    @currentInventoryThingClasses = new ComputedField =>
      # Wait for initialization to finish so that episodes have initialized as well.
      return unless LOI.adventureInitialized()

      thingClasses = for chapter in @currentChapters()
        chapter.inventory?()

      _.flatten thingClasses
