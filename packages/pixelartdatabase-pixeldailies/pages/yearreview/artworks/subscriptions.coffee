AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns submissions ordered by favorites count.
PADB.PixelDailies.Pages.YearReview.Artworks.mostPopular.publish (year, limit = 10) ->
  check year, Number
  check limit, Number

  PADB.PixelDailies.Pages.YearReview.Artworks.mostPopular.query year, limit
