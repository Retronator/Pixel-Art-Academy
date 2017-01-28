AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns submissions ordered by favorites count.
PADB.PixelDailies.Pages.YearReview.Day.themeSubmissions.publish (date, limit = 10) ->
  check date, Date
  check limit, Number

  PADB.PixelDailies.Pages.YearReview.Day.themeSubmissions.query date, limit
