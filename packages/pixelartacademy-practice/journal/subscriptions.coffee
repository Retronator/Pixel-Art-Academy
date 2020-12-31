AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get a specific journal.
PAA.Practice.Journal.forId.publish (journalId) ->
  check journalId, Match.DocumentId

  PAA.Practice.Journal.documents.find journalId

# Get journals for a certain character.
PAA.Practice.Journal.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.Journal.documents.find
    'character._id': characterId

# Get journals for a list of characters.
PAA.Practice.Journal.forCharacterIds.publish (characterIds) ->
  check characterIds, [Match.DocumentId]

  PAA.Practice.Journal.documents.find
    'character._id': $in: characterIds
