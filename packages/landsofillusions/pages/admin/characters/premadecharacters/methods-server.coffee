AB = Artificial.Babel
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Pages.Admin.Characters.PreMadeCharacters.insert.method ->
  RA.authorizeAdmin()

  # Create the bio translation.
  bioTranslationId = AB.Translation.documents.insert {}

  preMadeCharacter =
    bio:
      _id: bioTranslationId

  LOI.Character.PreMadeCharacter.documents.insert preMadeCharacter

LOI.Pages.Admin.Characters.PreMadeCharacters.setCharacter.method (preMadeCharacterId, characterId) ->
  check preMadeCharacterId, Match.DocumentId
  check characterId, Match.DocumentId

  RA.authorizeAdmin()

  LOI.Character.PreMadeCharacter.documents.update preMadeCharacterId,
    $set:
      'character._id': characterId
