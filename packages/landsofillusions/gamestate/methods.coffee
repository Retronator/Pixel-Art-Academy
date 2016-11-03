AE = Artificial.Everywhere
LOI = LandsOfIllusions

Meteor.methods
  'LandsOfIllusions.GameState.insertForCurrentUser': (state) ->
    check state, Object

    user = Retronator.user()
    throw new AE.UnauthorizedException "You must be logged in to insert game state." unless user

    existingGameState = LOI.GameState.documents.findOne 'user._id': user._id
    throw new AE.InvalidOperationException "This user already has a game state." if existingGameState
    
    # Set the registered variable on the state.
    state.registered = true

    # Insert the state.
    LOI.GameState.documents.insert
      user:
        _id: user._id
      state: state

  'LandsOfIllusions.GameState.update': (gameStateId, state) ->
    check gameStateId, Match.DocumentId
    check state, Object

    console.log "Updating game state in the database." if LOI.debug

    user = Retronator.user()
    throw new AE.UnauthorizedException "You must be logged in to update game state." unless user

    gameState = LOI.GameState.documents.findOne gameStateId
    throw new AE.ArgumentNullException "Provided game state does not exist." unless gameState

    # See if this is a user or character state.
    gameStateUser = gameState.user

    if gameState.character
      character = LOI.Character.findOne gameState.character._id
      gameStateUser = character.user

    throw new AE.UnauthorizedException "This game state does not belong to you." unless gameStateUser._id is user._id

    # Everything seems OK, write the state.
    LOI.GameState.documents.update gameStateId,
      $set:
        state: state
