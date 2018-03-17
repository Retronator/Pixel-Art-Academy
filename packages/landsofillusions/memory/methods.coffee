LOI = LandsOfIllusions

LOI.Memory.insert.method (memoryId, locationId) ->
  check memoryId, Match.documentId
  check locationId, Match.documentId
  
  # Only players can create memories.
  LOI.Authorize.player()

  LOI.Memory.documents.insert
    _id: memoryId
    locationId: locationId
