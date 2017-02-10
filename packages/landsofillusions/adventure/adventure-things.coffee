AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeThings: ->
    # We use caches to avoid reconstruction.
    @_things = {}

    # Returns all things that are available to listen to commands.
    @currentActiveThings = new ComputedField =>
      return unless currentLocation = @currentLocation()

      locationThingClasses = currentLocation.things()
      inventoryThingClasses = @currentInventoryThingClasses()
      sceneThingClasses = for scene in @currentScenes()
        scene.things()

      thingClasses = _.uniq _.flattenDeep _.union locationThingClasses, inventoryThingClasses, sceneThingClasses

      # Remove any thing classes that had conditional statements and could evaluate to undefined.
      thingClasses = _.without thingClasses, undefined

      for thingClass in thingClasses
        # Create the thing if needed. We create the instance in a non-reactive
        # context so that reruns of this autorun don't invalidate instance's autoruns.
        Tracker.nonreactive =>
          @_things[thingClass.id()] ?= new thingClass

        @_things[thingClass.id()]

    @currentInventoryThings = new ComputedField =>
      return unless currentActiveThings = @currentActiveThings()
      return unless currentInventoryThingClasses = @currentInventoryThingClasses()

      thing for thing in currentActiveThings when thing.constructor in currentInventoryThingClasses

    # Returns current things that are at the location (and not in the inventory).
    @currentLocationThings = new ComputedField =>
      return unless currentLocation = @currentLocation()
      return unless currentActiveThings = @currentActiveThings()

      # Things at the location are a union of fixed location things and temporary things placed by active scenes.
      locationThings = currentLocation.things()
      sceneThings = for scene in @currentScenes()
        scene.things()

      thingClasses = _.uniq _.flattenDeep _.union locationThings, sceneThings

      thing for thing in currentActiveThings when thing.constructor in thingClasses
