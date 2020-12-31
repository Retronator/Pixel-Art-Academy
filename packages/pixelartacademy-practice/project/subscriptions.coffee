AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get a specific project.
PAA.Practice.Project.forId.publish (journalId) ->
  check journalId, Match.DocumentId

  PAA.Practice.Project.documents.find journalId

# Get projects for a certain character.
PAA.Practice.Project.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.Project.documents.find
    'characters._id': characterId
