LOI = LandsOfIllusions

LOI.Memory.Action.forMemory.publish (memoryId) ->
  check memoryId, Match.DocumentId

  LOI.Memory.Action.documents.find
    'memory._id': memoryId

LOI.Memory.Action.forMemories.publish (memoryIds) ->
  check memoryIds, [Match.DocumentId]

  LOI.Memory.Action.documents.find
    'memory._id': $in: memoryIds

# Returns actions at a location within the duration.
LOI.Memory.Action.recentForTimelineLocation.publish (timelineId, locationId, earliestTime) ->
  check timelineId, String
  check locationId, String
  check earliestTime, Date

  LOI.Memory.Action.documents.find
    timelineId: timelineId
    locationId: locationId
    time: $gt: earliestTime

# Returns actions for a character within the duration.
LOI.Memory.Action.recentForCharacter.publish (characterId, earliestTime) ->
  check characterId, Match.DocumentId
  check earliestTime, Date

  LOI.Memory.Action.documents.find
    'character._id': characterId
    time: $gt: earliestTime

# Returns actions for characters within the duration.
LOI.Memory.Action.recentForCharacters.publish (characterIds, earliestTime) ->
  check characterIds, [Match.DocumentId]
  check earliestTime, Date

  LOI.Memory.Action.documents.find
    'character._id': $in: characterIds
    time: $gt: earliestTime
