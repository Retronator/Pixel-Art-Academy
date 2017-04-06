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

      # Remove thing classes that scenes dictate to remove.
      removedSceneThingClasses = for scene in @currentScenes()
        scene.removedThings()

      removedSceneThingClasses = _.uniq _.flattenDeep removedSceneThingClasses
      removedSceneThingClasses = _.without removedSceneThingClasses, undefined

      thingClasses = _.difference thingClasses, removedSceneThingClasses

      for thingClass in thingClasses
        # Create the thing if needed. We allow passing thing instances as well, so no need to instantiate those.
        if thingClass instanceof LOI.Adventure.Thing
          thingInstance = thingClass
          @_things[thingClass.id()] = thingInstance

        else
          # We create the instance in a non-reactive context so that
          # reruns of this autorun don't invalidate instance's autoruns.
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

      # Note: thing classes can also hold instances, if they were created manually by locations.
      thingClasses = _.uniq _.flattenDeep _.union locationThings, sceneThings

      thing for thing in currentPhysicalThings when thing.constructor in thingClasses or thing in thingClasses

  getCurrentThing: (thingClassOrId) ->
    thingClass = _.thingClass thingClassOrId
    things = @currentThings()

    _.find things, (thing) -> thing.constructor is thingClass
