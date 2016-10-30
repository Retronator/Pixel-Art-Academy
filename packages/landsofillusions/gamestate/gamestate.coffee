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
      
  update: ->
    # Update the whole state on the server.
    # TODO: Probably we could update only changed objects.
    Meteor.call 'LandsOfIllusions.GameState.update', @_id, @state

LOI.GameState = LandsOfIllusionsGameState
