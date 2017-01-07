AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# Get check-ins for a certain character.
Meteor.publish 'PixelArtAcademy.Practice.CheckIn.forCharacter', (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.CheckIn.documents.find
    'character._id': characterId

# Get practice check-ins for a certain date range.
Meteor.publish 'PixelArtAcademy.Practice.CheckIn.forDateRange', (dateRange) ->
  check dateRange, AE.DateRange

  query = {}

  query = dateRange.addToMongoQuery query, 'time'

  PAA.Practice.CheckIn.documents.find query,
    sort: 
      time: -1

Meteor.publish 'PixelArtAcademy.Practice.CheckIn.conversations', (checkInId) ->
  check checkInId, Match.DocumentId

  @autorun =>
    checkIn = PAA.Practice.CheckIn.documents.findOne checkInId,
      fields:
        conversations: 1

    return LOI.Conversations.Conversation.documents.find
      _id:
        $in: checkIn?.conversations or []
