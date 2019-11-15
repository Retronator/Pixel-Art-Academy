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
      _.uniq @_instantiateThings currentSituation.things()

    # Returns things that are in the inventory.
    @currentInventoryThings = new ComputedField =>
      return unless currentInventory = @currentInventory()
      _.uniq @_instantiateThings currentInventory.things()

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

    @currentPeople = new ComputedField =>
      _.filter @currentLocationThings(), (thing) => thing instanceof LOI.Character.Person

    @currentOtherPeople = new ComputedField =>
      _.without @currentPeople(), LOI.agent()

    @currentAgents = new ComputedField =>
      _.filter @currentLocationThings(), (thing) => thing instanceof LOI.Character.Agent

    @currentOtherAgents = new ComputedField =>
      _.without @currentAgents(), LOI.agent()

    @currentActors = new ComputedField =>
      _.filter @currentLocationThings(), (thing) => thing instanceof LOI.Character.Actor

  _instantiateThings: (things) ->
    for thing in things
      # Look if the thing was already an instance.
      if thing instanceof LOI.Adventure.Thing
        thingInstance = thing

      else
        # Look into our cache if we already instantiated this thing.
        thingId = _.thingId thing
        thingClass = _.thingClass thing
        thingInstance = null

        if thingEntries = @_things[thingId]
          thingEntry = _.find thingEntries, (thingEntry) => thingEntry.class is thingClass
          thingInstance = thingEntry?.instance

        unless thingInstance
          # We don't have an instance ready, so we'll have to create it. We do so in a non-reactive
          # context so that reruns of this autorun don't invalidate instance's autoruns.
          thingInstance = Tracker.nonreactive => new thingClass
          @_things[thingId] ?= []
          @_things[thingId].push
            class: thingClass
            instance: thingInstance

      thingInstance

  getThing: (thingClassOrId) ->
    thingClass = _.thingClass thingClassOrId

    unless thingClass
      console.warn "Unknown thing requested.", thingClassOrId
      return

    @_instantiateThings([thingClass])[0]

  getCurrentThing: (thingClassOrId) -> @_getThingInThings thingClassOrId, @currentThings()
  getCurrentInventoryThing: (thingClassOrId) -> @_getThingInThings thingClassOrId, @currentInventoryThings()
  getCurrentLocationThing: (thingClassOrId) -> @_getThingInThings thingClassOrId, @currentLocationThings()

  _getThingInThings: (thingClassOrId, things) ->
    thingClass = _.thingClass thingClassOrId

    # If we couldn't find a thing class, ID should be a character ID.
    characterId = thingClassOrId unless thingClass

    _.find things, (thing) =>
      if characterId
        thing.characterId?() is characterId

      else
        thing instanceof thingClass

  getAvatar: (thingClass) ->
    # Create the avatar if needed. It must be done in non-reactive
    # context so that subscriptions inside the avatar don't get stopped.
    Tracker.nonreactive =>
      @_avatarsByThingId[thingClass.id()] ?= thingClass.createAvatar()

    @_avatarsByThingId[thingClass.id()]
