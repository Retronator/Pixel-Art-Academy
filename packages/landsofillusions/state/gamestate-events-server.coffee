AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.GameState extends LOI.GameState
  @Meta
    name: @id()
    replaceParent: true

  # Helper method to add an event during event processing. It does not save changes to the database and is to be used from simulation only.
  addEventLocally: (event) ->
    event.id ?= Random.id()

    @events.push event

  # Helper method to remove an event during event processing. It does not save changes to the database and is to be used from simulation only.
  removeEventLocally: (eventOrId) ->
    eventId = eventOrId.id or eventOrId
    removedEvent = _.find @events, (event) => event.id is eventId

    throw new AE.InvalidOperationException "Event to be removed not found." unless removedEvent

    @events = _.without @events, removedEvent

  # Helper method to add an event.
  addEvent: (event) ->
    event.id ?= Random.id()

    events = @events.concat [event]

    LOI.GameState.documents.update @_id,
      $set: {events}

  # Helper method to remove an event.
  removeEvent: (eventOrId) ->
    eventId = eventOrId.id or eventOrId
    removedEvent = _.find @events, (event) => event.id is eventId

    throw new AE.InvalidOperationException "Event to be removed not found." unless removedEvent

    events = _.without @events, removedEvent

    LOI.GameState.documents.update @_id,
      $set: {events}

  # Returns the event from this game state.
  getEvent: (eventOrId) ->
    eventId = eventOrId.id or eventOrId

    eventData = _.find @events, (event) => event.id is eventId

    LOI.Adventure.Event.getEvent eventData, @
