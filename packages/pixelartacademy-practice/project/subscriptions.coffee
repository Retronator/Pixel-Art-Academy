AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get a specific project.
PAA.Practice.Project.forId.publish (projectId) ->
  check projectId, Match.DocumentId

  PAA.Practice.Project.documents.find projectId

# Get projects for a certain character.
PAA.Practice.Project.forCharacterId.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.Project.documents.find
    'characters._id': characterId
