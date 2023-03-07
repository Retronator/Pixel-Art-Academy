AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Memory.Progress.updateProgress.method (profileId, memoryId, time) ->
  check profileId, Match.DocumentId
  check memoryId, Match.DocumentId
  check time, Date

  updateProgress profileId, memoryId, time

LOI.Memory.Progress.discoverMemory.method (profileId, memoryId) ->
  check profileId, Match.DocumentId
  check memoryId, Match.DocumentId

  updateProgress profileId, memoryId

updateProgress = (profileId, memoryId, time) ->
  LOI.Authorize.profileAction profileId

  progress = LOI.Memory.Progress.documents.findOne 'profileId': profileId
  throw new AE.ArgumentException "Missing progress document for profile." unless progress

  memory = LOI.Memory.documents.findOne memoryId
  throw new AE.ArgumentException "Memory not found." unless memory

  # If we already have this memory, only allow updates that increase the time.
  existingObservedMemory = _.find progress.observedMemories, (observedMemory) -> observedMemory.memory._id is memoryId

  if existingObservedMemory
    if time and existingObservedMemory.time
      # If we already have this memory's time, only allow updates that increase the time.
      throw new AE.ArgumentException "Time can't be decreased." if time < existingObservedMemory.time

      # Nothing to do if we're not increasing it.
      return if time.getTime() is existingObservedMemory.time.getTime()
    
    setModifier = 'observedMemories.$.discovered': true
    setModifier['observedMemories.$.time'] = time if time

    LOI.Memory.Progress.documents.update
      _id: progress._id
      # Query the observedMemories field to find the correct array position.
      'observedMemories.memory._id': memoryId
    ,
      $set: setModifier

  else
    # We haven't observed this memory yet.
    observedMemory =
      memory:
        _id: memoryId
      discovered: true

    observedMemory.time = time if time
    
    LOI.Memory.Progress.documents.update progress._id,
      $push:
        observedMemories: observedMemory
