AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns the top 100 submissions with most favorites.
PADB.PixelDailies.Pages.Top2016.Themes.themes.publish (limit = 1) ->
  # Take top submissions in 2016.
  startDate = new Date 2016, 0, 1
  endDate = new Date 2016, limit, 1

  monthsRange = new AE.DateRange startDate, endDate

  submissionsQuery = {}

  monthsRange.addToMongoQuery submissionsQuery, 'time'

  themesCursor = PADB.PixelDailies.Theme.documents.find submissionsQuery,
    sort:
      date: 1
    fields:
      tweetData: 0

  themes = themesCursor.fetch()

  themeIds = (theme._id for theme in themes)

  submissionIds = []

  for themeId in themeIds
    topSubmission = PADB.PixelDailies.Submission.documents.findOne
      'theme._id': themeId
    ,
      sort:
        favoritesCount: -1

    submissionIds.push topSubmission._id if topSubmission

  submissionsCursor = PADB.PixelDailies.Submission.documents.find
    _id:
      $in: submissionIds
  ,
    sort:
      time: 1
    fields:
      tweetData: 0

  [themesCursor, submissionsCursor]
