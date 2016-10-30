AE = Artificial.Everywhere
LOI = LandsOfIllusions

Meteor.methods
  'LandsOfIllusions.GameState.update': (gameStateId, state) ->
    check gameStateId, Match.DocumentId
    check state, Object

    user = Retronator.user()
    throw new AE.UnauthorizedException "You must be logged in to update game state." unless user

    gameState = LOI.GameState.documents.findOne gameStateId
    throw new AE.ArgumentNullException "Provided game state does not exist." unless gameState

    # See if this is a user or character state.
    gameStateUser = gameState.user

    if gameState.character
      character = LOI.Character.findOne gameState.character._id
      gameStateUser = character.user

    throw new AE.UnauthorizedException "This game state does not belong to you." unless gameStateUser._id id user._id

    # Everything seems OK, write the state.
    LOI.GameState.update gameStateId,
      $set:
        state: state
