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

      things = _.union currentSituation.things(), currentInventory.things()

      for thing in things
        # Create the thing if needed. We allow passing thing instances as well, so no need to instantiate those.
        if thing instanceof LOI.Adventure.Thing
          thingInstance = thing
          @_things[thing.id()] = thingInstance

        else
          # We create the instance in a non-reactive context so that
          # reruns of this autorun don't invalidate instance's autoruns.
          Tracker.nonreactive =>
            @_things[thing.id()] ?= new thing

        @_things[thing.id()]

    # Returns all physical and storyline things that are available to listen to commands.
    @currentThings = new ComputedField =>
      things = _.uniq _.flattenDeep [
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
      return unless inventoryThings = @currentInventory().things()

      @_filterThings currentPhysicalThings, inventoryThings

    # Returns current things that are at the location (and not in the inventory).
    @currentLocationThings = new ComputedField =>
      return unless currentPhysicalThings = @currentPhysicalThings()
      return unless locationThings = @currentSituation().things()

      @_filterThings currentPhysicalThings, locationThings

  _filterThings: (sourceThings, filterThings) ->
    intersection = []

    # Note: source things are always instances, but filter things can be instances or classes.
    for sourceThing in sourceThings
      # Try and find the same instance or class in filter things.
      for filterThing in filterThings
        if sourceThing is filterThing or _.isFunction(filterThing) and sourceThing instanceof filterThing
          intersection.push sourceThing
          break

    intersection

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
