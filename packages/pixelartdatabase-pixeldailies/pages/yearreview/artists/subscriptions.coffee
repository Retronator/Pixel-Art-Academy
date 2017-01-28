AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns submissions ordered by favorites count.
PADB.PixelDailies.Pages.YearReview.Artists.highestRanked.publish (sortingParameter, year, limit) ->
  check sortingParameter, String
  check year, Number
  check limit, Number
  
  PADB.PixelDailies.Pages.YearReview.Artists.highestRanked.query sortingParameter, year, limit
