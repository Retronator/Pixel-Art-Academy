LOI = LandsOfIllusions

LOI.Memory.insert.method (memoryId, timelineId, locationId) ->
  check memoryId, Match.documentId
  check timelineId, String
  check locationId, String
  
  # Only players can create memories.
  LOI.Authorize.player()

  LOI.Memory.documents.insert
    _id: memoryId
    timelineId: timelineId
    locationId: locationId
