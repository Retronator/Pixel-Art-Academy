LOI = LandsOfIllusions

LOI.Memory.insert.method (locationId) ->
  check locationId, Match.documentId
  
  # Only players can create memories.
  LOI.Authorize.player()

  LOI.Memory.documents.insert {locationId}
