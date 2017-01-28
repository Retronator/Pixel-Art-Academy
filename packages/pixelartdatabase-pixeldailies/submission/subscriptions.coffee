AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Get Pixel Dailies themes for a certain date range.
PADB.PixelDailies.Submission.forTheme.publish (themeId) ->
  check themeId, Match.DocumentId

  PADB.PixelDailies.Submission.documents.find
    'theme._id': themeId
  ,
    fields:
      tweetData: 0
