LOI = LandsOfIllusions

LOI.Memory.getLastUndiscovered.method (profileId, timelineId, locationId, earliestTime) ->
  # Profile ID is optional and if not provided, the method simply returns the last memory.
  check profileId, Match.OptionalOrNull Match.DocumentId
  check timelineId, String
  check locationId, String
  check earliestTime, Date

  LOI.Authorize.profileAction profileId if profileId

  # Find profile's progress so we know which memories were already discovered.
  progress = LOI.Memory.Progress.documents.findOne 'profileId': profileId

  # Go over memories from last month and find the first one that is not discovered.
  recentMemories = LOI.Memory.documents.fetch
    timelineId: timelineId
    locationId: locationId
    endTime: $gt: earliestTime
  ,
    sort: endTime: -1

  # If we don't have any observed memories at all, just return the last memory.
  return _.last(recentMemories)?._id unless progress?.observedMemories?.length
      
  for recentMemory in recentMemories
    observedMemory = _.find progress.observedMemories, (observedMemory) -> observedMemory.memory._id is recentMemory._id

    # Skip memories we've already discovered.
    continue if observedMemory?.discovered

    # Skip memories we were part of.
    continue if _.find recentMemory.actions, (action) -> action.profileId is profileId

    return recentMemory._id

  # We couldn't find an undiscovered memory.
  null
