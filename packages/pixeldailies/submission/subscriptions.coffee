AE = Artificial.Everywhere
PAA = PixelArtAcademy

# Get Pixel Dailies themes for a certain date range.
Meteor.publish 'PAA.PixelDailies.Submissions.forTheme', (themeId) ->
  check themeId, Match.DocumentId

  PAA.PixelDailies.Submission.documents.find
    'theme._id': themeId
  ,
    fields:
      tweetData: 0
