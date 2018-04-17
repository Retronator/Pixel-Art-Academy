LOI = LandsOfIllusions

LOI.Memory.forId.publish (memoryId) ->
  check memoryId, Match.DocumentId
  
  LOI.Memory.documents.find memoryId

LOI.Memory.forIds.publish (memoryIds) ->
  check memoryIds, [Match.DocumentId]

  LOI.Memory.documents.find _id: $in: memoryIds

LOI.Memory.forCharacter.publish (characterId, limit) ->
  check characterId, Match.DocumentId
  check limit, Match.Integer

  LOI.Memory.forCharacter.query characterId, limit
