AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeThings: ->
    @currentSituation = new ComputedField =>
      options =
        timelineId: @currentTimelineId()
        location: @currentLocation()
        context: @currentContext()

      return unless options.timelineId and options.location

      new LOI.Adventure.Situation options
      
    @currentSituationParameters = new ComputedField =>
      timelineId: @currentTimelineId()
      locationId: @currentLocationId()
      contextId: @currentContext()?.id()

    # We use caches to avoid reconstruction.
    @_things = {}
    @_avatarsByThingId = {}

    # Instantiates and returns all physical things (items, characters) that are available to listen to commands.
    @currentPhysicalThings = new ComputedField =>
      return unless currentSituation = @currentSituation()
      return unless currentInventory = @currentInventory()

      thingClasses = _.union currentSituation.things(), currentInventory.things()

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
        @activeScenes()
        @currentLocation()
        @currentContext()
        @currentPhysicalThings()
      ]

      _.without things, undefined, null

    @currentInventoryThings = new ComputedField =>
      return unless currentPhysicalThings = @currentPhysicalThings()
      return unless currentInventoryThingClasses = @currentInventory().things()

      # Note: thing classes can also hold instances, if they were created manually by locations.
      thing for thing in currentPhysicalThings when thing.constructor in currentInventoryThingClasses or thing in currentInventoryThingClasses

    # Returns current things that are at the location (and not in the inventory).
    @currentLocationThings = new ComputedField =>
      return unless currentSituation = @currentSituation()
      return unless currentPhysicalThings = @currentPhysicalThings()

      locationThingClasses = _.union currentSituation.things()

      # Note: thing classes can also hold instances, if they were created manually by locations.
      thing for thing in currentPhysicalThings when thing.constructor in locationThingClasses or thing in locationThingClasses

  getCurrentThing: (thingClassOrId) ->
    thingClass = _.thingClass thingClassOrId
    things = @currentThings()

    _.find things, (thing) -> thing instanceof thingClass

  getAvatar: (thingClass) ->
    # Create the avatar if needed. It must be done in non-reactive
    # context so that subscriptions inside the avatar don't get stopped.
    Tracker.nonreactive =>
      @_avatarsByThingId[thingClass.id()] ?= thingClass.createAvatar()

    @_avatarsByThingId[thingClass.id()]
