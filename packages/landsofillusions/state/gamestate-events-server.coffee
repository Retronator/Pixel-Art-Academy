AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.GameState extends LOI.GameState
  @Meta
    name: @id()
    replaceParent: true

  addEvent: (event) ->
    event.id ?= Random.id()

    events = @events.concat [event]

    LOI.GameState.documents.update @_id,
      $set:
        'state.events': events

  removeEvent: (eventOrId) ->
    eventId = eventOrId.id or eventOrId
    removedEvent = _.find @events, (event) => event.id is eventId

    events = _.without @events, removedEvent

    LOI.GameState.documents.update @_id,
      $set:
        'state.events': events

  getEvent: (eventOrId) ->
    eventId = eventOrId.id or eventOrId

    eventData = _.find @events, (event) => event.id is eventId

    LOI.Adventure.Event.getEvent eventData, @state
