AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get check-ins for a certain character.
PAA.Practice.CheckIn.forCharacterId.publish (characterId, limit) ->
  check characterId, Match.DocumentId

  PAA.Practice.CheckIn.documents.find
    'character._id': characterId
  ,
    limit: limit
    sort:
      time: -1

# Get practice check-ins for a certain date range.
PAA.Practice.CheckIn.forDateRange.publish (dateRange) ->
  check dateRange, AE.DateRange

  query = {}

  dateRange.addToMongoQuery query, 'time'

  PAA.Practice.CheckIn.documents.find query,
    sort:
      time: -1

PAA.Practice.CheckIn.memoriesForCheckInId.publish (checkInId) ->
  check checkInId, Match.DocumentId

  @autorun =>
    checkIn = PAA.Practice.CheckIn.documents.findOne checkInId,
      fields:
        memories: 1

    return LOI.Memory.documents.find
      _id:
        $in: checkIn?.memories or []
