AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Get Pixel Dailies themes for a certain date range.
PADB.PixelDailies.Theme.forDateRange.publish (dateRange) ->
  check dateRange, AE.DateRange

  query =
    hashtags:
      $exists: 1

  query = dateRange.addToMongoQuery query, 'time'

  PADB.PixelDailies.Theme.documents.find query,
    fields:
      tweetData: 0
