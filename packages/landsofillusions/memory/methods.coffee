LOI = LandsOfIllusions

LOI.Memory.insert.method (memoryId, timelineId, locationId, contextId) ->
  check memoryId, Match.DocumentId
  check timelineId, String
  check locationId, String
  check contextId, Match.OptionalOrNull String

  # Only players can create memories.
  LOI.Authorize.player()

  memory =
    _id: memoryId
    timelineId: timelineId
    locationId: locationId

  memory.contextId = contextId if contextId

  LOI.Memory.documents.insert memory
