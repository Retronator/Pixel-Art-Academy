AE = Artificial.Everywhere
PAA = PixelArtAcademy

# Get Pixel Dailies themes for a certain date range.
Meteor.publish 'characterCheckIns', (characterId) ->
  check characterId, Match.DocumentId

  PAA.Practice.CheckIn.documents.find
    'character._id': characterId

# Get practice check-ins for a certain date range.
Meteor.publish 'practiceCheckIns', (dateRange) ->
  check dateRange, AE.DateRange

  query = {}

  query = dateRange.addToMongoQuery query, 'time'

  PAA.Practice.CheckIn.documents.find query,
    sort: 
      time: -1
