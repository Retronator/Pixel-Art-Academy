AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns the themes in the given year with the top submission for each theme.
PADB.PixelDailies.Pages.YearReview.ThemesCalendarProvider.themes.publish (year, limit = 50) ->
  check year, Number
  check limit, Number

  # A zero Mongo limit is unbounded, so publish nothing until the client requests a page.
  return @ready() unless limit > 0

  yearRange = new AE.DateRange year: year

  themesQuery =
    submissionsCount:
      $gt: 0
    processingError:
      $exists: false

  yearRange.addToMongoQuery themesQuery, 'time'

  PADB.PixelDailies.Theme.documents.find themesQuery,
    sort:
      time: 1
    limit: limit
    fields:
      tweetData: 0
