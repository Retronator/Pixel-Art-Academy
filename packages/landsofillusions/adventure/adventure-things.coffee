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

    # Returns things that are at the location (and not in the inventory).
    @currentLocationThings = new ComputedField =>
      return unless currentSituation = @currentSituation()
      @_instantiateThings currentSituation.things()

    # Returns things that are in the inventory.
    @currentInventoryThings = new ComputedField =>
      return unless currentInventory = @currentInventory()
      @_instantiateThings currentInventory.things()

    # Returns all physical things (items, characters) that are available to listen to commands.
    @currentPhysicalThings = new ComputedField =>
      return unless currentLocationThings = @currentLocationThings()
      return unless currentInventoryThings = @currentInventoryThings()

      _.union currentLocationThings, currentInventoryThings

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

  _instantiateThings: (things) ->
    for thing in things
      thingId = thing.id()

      # Look if the thing was already an instance.
      if thing instanceof LOI.Adventure.Thing
        thingInstance = thing

      # Look into our cache if we already instantiated this thing.
      else if @_things[thingId]
        thingInstance = @_things[thingId]

      else
        # We don't have an instance ready, so we'll have to create it. We do so in a non-reactive
        # context so that reruns of this autorun don't invalidate instance's autoruns.
        thingInstance = Tracker.nonreactive => new thing
        @_things[thingId] = thingInstance

      thingInstance

  getCurrentThing: (thingClassOrId) ->
    thingClass = _.thingClass thingClassOrId
    things = @currentThings()

    _.find things, (thing) -> thing instanceof thingClass

  getCurrentInventoryThing: (thingClassOrId) ->
    thingClass = _.thingClass thingClassOrId
    things = @currentInventoryThings()

    _.find things, (thing) -> thing instanceof thingClass

  getAvatar: (thingClass) ->
    # Create the avatar if needed. It must be done in non-reactive
    # context so that subscriptions inside the avatar don't get stopped.
    Tracker.nonreactive =>
      @_avatarsByThingId[thingClass.id()] ?= thingClass.createAvatar()

    @_avatarsByThingId[thingClass.id()]
