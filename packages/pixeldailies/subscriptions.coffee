AE = Artificial.Everywhere
PAA = PixelArtAcademy

# Get Pixel Dailies themes for a certain date range.
Meteor.publish 'pixelDailiesThemes', (dateRange) ->
  check dateRange, Match.DateRange

  dateRange = new AE.DateRange dateRange
  start = dateRange.start()
  end = dateRange.end()

  query =
    hashtag:
      $exists: true

  query.start = $gte: start if start
  query.end = $lt: end if end

  PAA.PixelDailies.Theme.documents.find query,
    fields:
      tweetData: 0
