AM = Artificial.Mummification
LOI = LandsOfIllusions

class LandsOfIllusionsGameState extends AM.Document
  # state: object that holds all game information
  #   player
  #     inventory
  #   things
  #     scripts
  # user: the user this state belongs to or null if it's a character state
  #   _id
  # character: the character this state belongs to or null if it's a user state
  #   _id
  @Meta
    name: 'LandsOfIllusionsGameState'
    fields: =>
      user: @ReferenceField Retronator.Accounts.User
      character: @ReferenceField LOI.Character

  constructor: ->
    super

    # On the client also transform state from underscores to dots.
    @state = @constructor._transformStateFromDatabase @state if Meteor.isClient

  @insertForCurrentUser: (state, callback) ->
    Meteor.call 'LandsOfIllusions.GameState.insertForCurrentUser', @_prepareStateForDatabase(state), callback

  updated: ->
    # Only send updates to the server every 10 seconds.
    unless @_updated
      @_updated = _.throttle =>
        # Update the whole state on the server.
        # TODO: Probably we could update only changed objects.
        Meteor.call 'LandsOfIllusions.GameState.update', @_id, @constructor._prepareStateForDatabase @state
      ,
        10000
      ,
        leading: false

    @_updated()

  @_prepareStateForDatabase: (state) ->
    @_renameKeys state, /\./g, '_'

  @_transformStateFromDatabase: (state) ->
    @_renameKeys state, /_/g, '.'

  @_renameKeys: (entity, from, to) ->
    if _.isObject entity
      clone = {}
      for key, value of entity
        renamedKey = key.replace from, to
        clone[renamedKey] = @_renameKeys value, from, to

    else if _.isArray entity
      clone = []
      for arrayEntity in entity
        clone.push @_renameKeys arrayEntity, from, to

    else
      # Simply return the entity.
      clone = entity

    clone



LOI.GameState = LandsOfIllusionsGameState
