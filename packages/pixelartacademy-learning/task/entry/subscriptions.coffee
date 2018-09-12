LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Learning.Task.Entry.forCharacter.publish (characterId) ->
  check characterId, Match.DocumentId

  LOI.Authorize.characterAction characterId

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId

PAA.Learning.Task.Entry.forCharacterTaskIds.publish (characterId, taskIds) ->
  check characterId, Match.DocumentId
  check taskIds, [String]

  LOI.Authorize.characterAction characterId

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId
    taskId: $in: taskIds
