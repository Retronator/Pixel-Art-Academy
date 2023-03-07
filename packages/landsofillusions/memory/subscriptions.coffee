RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Memory.all.publish (limit = 10) ->
  check limit, Match.Integer

  RA.authorizeAdmin()

  LOI.Memory.documents.find {},
    sort:
      endTime: -1
    limit: limit

LOI.Memory.allWithActionsOfType.publish (actionType, limit = 10) ->
  check actionType, String
  check limit, Match.Integer

  RA.authorizeAdmin()

  LOI.Memory.documents.find
    'actions.type': actionType
  ,
    sort:
      endTime: -1
    limit: limit

LOI.Memory.forId.publish (memoryId) ->
  check memoryId, Match.DocumentId
  
  LOI.Memory.documents.find memoryId

LOI.Memory.forIds.publish (memoryIds) ->
  check memoryIds, [Match.DocumentId]

  LOI.Memory.documents.find _id: $in: memoryIds

LOI.Memory.forProfile.publish (profileId, limit) ->
  check profileId, Match.DocumentId
  check limit, Match.Integer

  LOI.Memory.forProfile.query profileId, limit
