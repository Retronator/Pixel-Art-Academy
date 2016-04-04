AE = Artificial.Everywhere
PAA = PixelArtAcademy

# Get Pixel Dailies themes for a certain date range.
Meteor.publish 'pixelDailiesThemes', (dateRange) ->
  check dateRange, AE.DateRange

  query =
    hashtag:
      $exists: true

  query = dateRange.addToMongoQuery query, 'date'

  PAA.PixelDailies.Theme.documents.find query,
    fields:
      tweetData: 0
