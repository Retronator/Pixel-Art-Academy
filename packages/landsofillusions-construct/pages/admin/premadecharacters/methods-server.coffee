AB = Artificial.Babel
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Construct.Pages.Admin.PreMadeCharacters.insert.method ->
  RA.authorizeAdmin()

  # Create the bio translation.
  bioTranslationId = AB.Translation.documents.insert {}

  preMadeCharacter =
    bio:
      _id: bioTranslationId

  LOI.Construct.Loading.PreMadeCharacter.documents.insert preMadeCharacter

LOI.Construct.Pages.Admin.PreMadeCharacters.setCharacter.method (preMadeCharacterId, characterId) ->
  check preMadeCharacterId, Match.DocumentId
  check characterId, Match.DocumentId

  RA.authorizeAdmin()

  LOI.Construct.Loading.PreMadeCharacter.documents.update preMadeCharacterId,
    $set:
      'character._id': characterId
