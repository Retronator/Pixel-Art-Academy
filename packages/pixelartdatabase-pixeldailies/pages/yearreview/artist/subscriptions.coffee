AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns the themes in the given year with the top submission for each theme.
PADB.PixelDailies.Pages.YearReview.Artist.CalendarProvider.submissions.publish (screenName, year, limit = 50) ->
  check screenName, String
  check year, Number
  check limit, Number

  # A zero Mongo limit is unbounded, so publish nothing until the client requests a page.
  return @ready() unless limit > 0

  PADB.PixelDailies.Pages.YearReview.Artist.CalendarProvider.submissions.query screenName, year, limit

# Returns submissions ordered by favorites count.
PADB.PixelDailies.Pages.YearReview.Artist.mostPopular.publish (screenName, year, limit = 10) ->
  check screenName, String
  check year, Number
  check limit, Number
  
  PADB.PixelDailies.Pages.YearReview.Artist.mostPopular.query screenName, year, limit
