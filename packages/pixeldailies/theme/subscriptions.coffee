AE = Artificial.Everywhere
PAA = PixelArtAcademy

# Get Pixel Dailies themes for a certain date range.
Meteor.publish 'PAA.PixelDailies.Theme.forDateRange', (dateRange) ->
  check dateRange, AE.DateRange

  query =
    hashtags:
      $exists: 1

  query = dateRange.addToMongoQuery query, 'time'

  PAA.PixelDailies.Theme.documents.find query,
    fields:
      tweetData: 0
