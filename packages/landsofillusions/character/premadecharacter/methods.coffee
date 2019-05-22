AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Character.PreMadeCharacter.cloneToCurrentUser.method (preMadeCharacterId, name) ->
  check preMadeCharacterId, Match.DocumentId
  check name, String

  user = Retronator.requireUser()

  # User must be a player.
  LOI.Authorize.player()

  # Find the selected pre-made character.
  preMadeCharacter = LOI.Character.PreMadeCharacter.documents.findOne preMadeCharacterId
  throw new AE.ArgumentException "Desired pre-made character does not exist." unless preMadeCharacter

  # Find the character we're cloning.
  character = LOI.Character.documents.findOne preMadeCharacter.character._id
  throw new AE.InvalidOperationException "Pre-made character's data is missing." unless character

  # Create a plain object out of character
  characterData = {}
  for own key, value of character when key isnt '_id'
    characterData[key] = value

  # Set up the new user.
  characterData.user =
    _id: user._id

  # Clone name translation.
  nameTranslationId = AB.Translation.documents.insert
    ownerId: user._id

  AB.Translation._update nameTranslationId, '', name

  characterData.avatar.fullName =
    _id: nameTranslationId

  # Approve the character.
  characterData.designApproved = true
  characterData.behaviorApproved = true

  # Insert the new character.
  characterId = LOI.Character.documents.insert characterData

  # Activate the character (we call the activate method because it also creates the game state.
  LOI.Character.activate characterId

  characterId
