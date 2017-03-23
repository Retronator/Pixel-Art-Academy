AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeThings: ->
    # We use caches to avoid reconstruction.
    @_things = {}

    # Instantiates and returns all physical things (items, characters) that are available to listen to commands.
    @currentPhysicalThings = new ComputedField =>
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

    # Returns all physical and storyline things that are available to listen to commands.
    @currentThings = new ComputedField =>
      things = _.flattenDeep [
        @episodes()
        @currentChapters()
        @currentSections()
        @currentScenes()
        @currentLocation()
        @currentPhysicalThings()
      ]

      _.without things, undefined

    @currentInventoryThings = new ComputedField =>
      return unless currentPhysicalThings = @currentPhysicalThings()
      return unless currentInventoryThingClasses = @currentInventoryThingClasses()

      thing for thing in currentPhysicalThings when thing.constructor in currentInventoryThingClasses

    # Returns current things that are at the location (and not in the inventory).
    @currentLocationThings = new ComputedField =>
      return unless currentLocation = @currentLocation()
      return unless currentPhysicalThings = @currentPhysicalThings()

      # Things at the location are a union of fixed location things and temporary things placed by active scenes.
      locationThings = currentLocation.things()
      sceneThings = for scene in @currentScenes()
        scene.things()

      thingClasses = _.uniq _.flattenDeep _.union locationThings, sceneThings

      thing for thing in currentPhysicalThings when thing.constructor in thingClasses

  getCurrentThing: (thingClassOrId) ->
    thingClass = _.thingClass thingClassOrId
    things = @currentThings()

    _.find things, (thing) -> thing.constructor is thingClass
