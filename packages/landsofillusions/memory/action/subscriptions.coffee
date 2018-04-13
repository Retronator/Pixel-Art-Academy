LOI = LandsOfIllusions

LOI.Memory.Action.forMemory.publish (memoryId) ->
  check memoryId, Match.DocumentId

  LOI.Memory.Action.documents.find
    'memory._id': memoryId

# Returns actions at a location within the duration.
LOI.Memory.Action.recentForTimelineLocation.publish (timelineId, locationId, durationInSeconds) ->
  check timelineId, String
  check locationId, String
  check durationInSeconds, Number
  
  earliestTime = new Date Date.now() - durationInSeconds * 1000

  LOI.Memory.Action.documents.find
    timelineId: timelineId
    locationId: locationId
    time: $gt: earliestTime
