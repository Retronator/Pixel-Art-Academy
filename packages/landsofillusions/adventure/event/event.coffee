LOI = LandsOfIllusions

# Represents an event that needs to happen on the server.
class LOI.Adventure.Event
  @_eventClassesByType = {}

  # Id string for this event used to identify the event in code.
  @type: -> throw new AE.NotImplementedException "You must specify event's type id."

  @getClassForType: (type) ->
    @_eventClassesByType[type]

  @initialize: ->
    # Store event class by ID.
    @_eventClassesByType[@type()] = @

  @getEvent: (eventData, gameStateDocument) ->
    eventClass = @getClassForType eventData.type
    new eventClass eventData, gameStateDocument

  constructor: (@data, @gameStateDocument) ->
    @id = @data.id
    @gameTime = @data.gameTime
    @gameState = @gameStateDocument.state
    @readOnlyGameState = @gameStateDocument.readOnlyState

  # Returns the real time when this event should be scheduled for simulation on the server.
  simulateAtTime: ->
    gameTimeToEvent = @gameTime - @gameState.gameTime
    realTimeToEvent = LOI.Time.simulatedGameTimeToRealTimeDuration gameTimeToEvent

    # Our origin is the real time when the last game time was reported.
    realTimeOrigin = @gameStateDocument.stateLastUpdatedAt.getTime()

    new Date realTimeOrigin + realTimeToEvent

  # Implement what happens when event takes place.
  process: -> throw new AE.NotImplementedException "You must specify event's process function."
