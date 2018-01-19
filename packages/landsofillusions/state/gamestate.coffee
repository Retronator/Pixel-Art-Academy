AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.GameState extends AM.Document
  @id: -> 'LandsOfIllusions.GameState'
  # state: object that holds all game information
  #   things: a map of all things
  #     {thingId}: state of the thing
  #   scripts: a map of all scripts
  #     {scriptId}: state of the script
  #   currentLocationId: the last known location of the player
  #   currentTimelineId: the last known timeline in which the player is
  #   time: integer number of seconds the player has spent in the game
  #   gameTime: fractional number of days passed in the game
  # events: array of events that need to execute on the server
  #   id: id of the event instance
  #   type: type id of the event class that handles this event
  #   gameTime: when the event happens in game time
  #   ... any custom data of the event
  # nextSimulateTime: auto-generated real life time when the next simulation should happen on the server
  # user: the user this state belongs to or null if it's a character state
  #   _id
  #   displayName
  # character: the character this state belongs to or null if it's a user state
  #   _id
  #   debugName
  # lastUpdated: auto-updated time when game state was last written to
  @Meta
    name: @id()
    fields: =>
      user: @ReferenceField Retronator.Accounts.User, ['displayName']
      character: @ReferenceField LOI.Character, ['debugName']
      nextSimulateTime: @GeneratedField 'self', ['events'], (fields) ->
        return [fields._id, null] unless fields.events?.length

        earliestEvent = _.first _.sortBy fields.events, 'gameTime'
        eventInstance = LOI.Adventure.Event.getEvent earliestEvent, LOI.GameState.documents.findOne(fields._id).state
        
        [fields._id, eventInstance.simulateAtTime()]

    triggers: =>
      updateLastUpdated: @Trigger ['state'], (newDocument, oldDocument) ->
        # Don't do anything when document is removed.
        return unless newDocument?._id

        LOI.GameState.documents.update newDocument._id,
          $set:
            lastUpdated: new Date()

  # We define these privately because we have custom public methods
  # that transform the state locally before passing it on to the server.
  @_insertForCurrentUser: @method 'insertForCurrentUser'
  @_clearForCurrentUser: @method 'clearForCurrentUser'
  @_replaceForCurrentUser: @method 'replaceForCurrentUser'

  @_insertForCharacter: @method 'insertForCharacter'
  @_clearForCharacter: @method 'clearForCharacter'
  @_replaceForCharacter: @method 'replaceForCharacter'

  @update: @method 'update'
      
  @forCurrentUser: @subscription 'forCurrentUser'
  @forCharacter: @subscription 'forCharacter'

  constructor: ->
    super

    # On the client also transform state from underscores to dots.
    @state = @constructor._transformStateFromDatabase @state if Meteor.isClient

  @insertForCurrentUser: (state, callback) ->
    LOI.GameState._insertForCurrentUser @_prepareStateForDatabase(state), callback

  @clearForCurrentUser: (callback) ->
    LOI.GameState._clearForCurrentUser callback

  @replaceForCurrentUser: (state, callback) ->
    LOI.GameState._replaceForCurrentUser @_prepareStateForDatabase(state), callback

  @insertForCharacter: (characterId, callback) ->
    LOI.GameState._insertForCharacter characterId, callback

  @clearForCharacter: (characterId, callback) ->
    LOI.GameState._clearForCharacter characterId, callback

  @replaceForCharacter: (characterId, state, callback) ->
    LOI.GameState._replaceForCharacter characterId, @_prepareStateForDatabase(state), callback

  updated: (options = {}) ->
    # Prepare the helper function that sends updates to the server only every 10 seconds.
    unless @_throttledUpdate
      @_throttledUpdate = _.throttle (options) =>
        @_update options
      ,
        10000
      ,
        leading: false

    # Call the throttled update.
    @_throttledUpdate options

    if options.flush
      # Flush to force immediate execution.
      @_throttledUpdate.flush()

  _update: (options) ->
    # Update the whole state on the server.
    # TODO: Probably we could update only changed objects.
    Meteor.call 'LandsOfIllusions.GameState.update', @_id, @constructor._prepareStateForDatabase(@state), (error, result) =>
      options.callback? error, result

  @_prepareStateForDatabase: (state) ->
    @_renameKeys state, /\./g, '_'

  @_transformStateFromDatabase: (state) ->
    @_renameKeys state, /_/g, '.'

  @_renameKeys: (entity, from, to) ->
    if _.isArray entity
      clone = []
      for arrayEntity in entity
        clone.push @_renameKeys arrayEntity, from, to

    else if _.isObject entity
      clone = {}
      for key, value of entity
        renamedKey = key.replace from, to
        clone[renamedKey] = @_renameKeys value, from, to

    else
      # Simply return the entity.
      clone = entity

    clone
