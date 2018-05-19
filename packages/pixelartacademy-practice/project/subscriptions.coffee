AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get journals for a certain character.
PAA.Practice.Project.forId.publish (journalId) ->
  check journalId, Match.DocumentId

  PAA.Practice.Project.documents.find journalId

# Get journals for a certain character.
PAA.Practice.Project.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.Project.documents.find
    'characters._id': characterId
