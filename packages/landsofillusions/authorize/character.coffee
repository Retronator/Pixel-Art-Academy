AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Authorize.characterAction = (characterId) ->
  # You need to be logged-in to perform actions with the character.
  user = Retronator.requireUser()

  # Character must exist.
  character = LOI.Character.documents.findOne characterId
  throw new AE.ArgumentException "Character not found." unless character

  # The character must belong to the logged-in user.
  throw new AE.UnauthorizedException "The character must belong to you." unless character.user._id is user._id
  
  character

LOI.Authorize.characterGameplayAction = (characterId) ->
  character = LOI.Authorize.characterAction characterId

  # Character must be activated.
  throw new AE.InvalidOperationException "Character is not activated." unless character.activated

  # Character must have a game state.
  gameState = LOI.GameState.documents.findOne 'character._id': characterId
  throw new AE.InvalidOperationException "Character does not have a game state." unless gameState

  {character, gameState}
