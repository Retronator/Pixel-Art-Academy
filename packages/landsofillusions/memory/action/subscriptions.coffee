RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Memory.Action.all.publish (limit = 10) ->
  check limit, Match.Integer

  RA.authorizeAdmin()

  LOI.Memory.Action.documents.find {},
    sort:
      time: -1
    limit: limit

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

# Returns actions for a profile within the duration.
LOI.Memory.Action.recentForProfile.publish (profileId, earliestTime) ->
  check profileId, Match.DocumentId
  check earliestTime, Date

  LOI.Memory.Action.documents.find
    'profileId': profileId
    time: $gt: earliestTime

# Returns actions for profiles within the duration.
LOI.Memory.Action.recentForProfiles.publish (profileIds, earliestTime) ->
  check profileIds, [Match.DocumentId]
  check earliestTime, Date

  LOI.Memory.Action.documents.find
    'profileId': $in: profileIds
    time: $gt: earliestTime
