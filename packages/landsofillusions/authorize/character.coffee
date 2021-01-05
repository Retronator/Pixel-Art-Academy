AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Authorize.characterAction = (characterId) ->
  # You need to be logged-in to perform actions with the character.
  user = Retronator.requireUser()

  # Character must exist.
  character = LOI.Character.documents.findOne characterId
  throw new AE.ArgumentException "Character not found." unless character

  # The character must belong to the logged-in user, or it is an admin performing the action.
  characterBelongsToUser = false

  if Meteor.isServer
    # On the server we can look directly for the user on the character document.
    characterBelongsToUser = character.user._id is user._id

  else
    # On the client we don't have the user field on the character, so we must instead look at user's character array.
    foundCharacter = _.find user.characters, (userCharacter) -> userCharacter._id is character._id
    characterBelongsToUser = true if foundCharacter

  unless characterBelongsToUser or user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin
    throw new AE.UnauthorizedException "The character must belong to you."
  
  character

LOI.Authorize.characterGameplayAction = (characterId) ->
  character = LOI.Authorize.characterAction characterId

  # Character must be activated.
  throw new AE.InvalidOperationException "Character is not activated." unless character.activated

  # Character must have a game state.
  gameState = LOI.GameState.documents.findOne 'character._id': characterId
  throw new AE.InvalidOperationException "Character does not have a game state." unless gameState

  {character, gameState}
