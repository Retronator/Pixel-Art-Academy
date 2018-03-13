LOI = LandsOfIllusions

LOI.Memory.Action.forMemory.publish (memoryId) ->
  check memoryId, Match.DocumentId

  LOI.Memory.Action.documents.find
    'memory._id': memoryId
