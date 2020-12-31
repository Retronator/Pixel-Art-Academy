LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Learning.Task.Entry.forCharacter.publish (characterId) ->
  check characterId, Match.DocumentId

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId

# Returns actions for a character within the duration.
PAA.Learning.Task.Entry.recentForCharacter.publish (characterId, earliestTime) ->
  check characterId, Match.DocumentId
  check earliestTime, Date

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId
    time: $gt: earliestTime

PAA.Learning.Task.Entry.forCharacterTaskIds.publish (characterId, taskIds) ->
  check characterId, Match.DocumentId
  check taskIds, [String]

  PAA.Learning.Task.Entry.documents.find
    'character._id': characterId
    taskId: $in: taskIds

PAA.Learning.Task.Entry.forCharactersTaskId.publish (characterIds, taskId) ->
  check characterIds, [Match.DocumentId]
  check taskId, String

  PAA.Learning.Task.Entry.documents.find
    'character._id': $in: characterIds
    taskId: taskId
