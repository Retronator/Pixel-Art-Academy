AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get journals for a certain character.
PAA.Practice.Journal.forId.publish (journalId) ->
  check journalId, Match.DocumentId

  PAA.Practice.Journal.documents.find journalId

# Get journals for a certain character.
PAA.Practice.Journal.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.Journal.documents.find
    'character._id': characterId
