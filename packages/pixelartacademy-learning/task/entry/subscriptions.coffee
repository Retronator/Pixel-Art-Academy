LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Note: We allow to read all entries only for the player's character.
PAA.Learning.Task.Entry.forCharacter.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId

PAA.Learning.Task.Entry.forCharacterTaskIds.publish (characterId, taskIds) ->
  check characterId, Match.DocumentId
  check taskIds, [String]

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId
    taskId: $in: taskIds
