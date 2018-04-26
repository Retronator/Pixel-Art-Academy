AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Memory.Progress.updateProgress.method (characterId, memoryId, time) ->
  check characterId, Match.DocumentId
  check memoryId, Match.DocumentId
  check time, Date

  LOI.Authorize.characterAction characterId

  progress = LOI.Memory.Progress.documents.findOne 'character._id': characterId
  throw new AE.ArgumentException "Missing progress document for character." unless progress

  memory = LOI.Memory.documents.findOne memoryId
  throw new AE.ArgumentException "Memory not found." unless memory

  # If we already have this memory, only allow updates that increase the time.
  existingObservedMemory = _.find progress.observedMemories, (observedMemory) -> observedMemory.memory._id is memoryId

  if existingObservedMemory
    throw new AE.ArgumentException "Time can't be decreased." if time < existingObservedMemory.time

    # Nothing to do if we're not increasing it.
    return if time.getTime() is existingObservedMemory.time.getTime()

    LOI.Memory.Progress.documents.update
      _id: progress._id
      # Query the observedMemories field to find the correct array position.
      'observedMemories.memory._id': memoryId
    ,
      $set:
        'observedMemories.$.time': time

  else
    # We haven't observed this memory yet.
    LOI.Memory.Progress.documents.update progress._id,
      $push:
        observedMemories:
          memory:
            _id: memoryId
          time: time
