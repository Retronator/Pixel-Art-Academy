LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Learning.Task.Entry.insert.method (characterId, taskId) ->
  check characterId, Match.DocumentId
  check taskId, String

  LOI.Authorize.characterAction characterId

  # Make sure we don't already have an entry for this task. This should not
  # raise an exception since the client might not have received the entry yet.
  existing = PAA.Learning.Task.Entry.documents.findOne
    'character._id': characterId
    taskId: taskId

  return if existing

  PAA.Learning.Task.Entry.documents.insert
    character:
      _id: characterId
    taskId: taskId
    time: new Date()
