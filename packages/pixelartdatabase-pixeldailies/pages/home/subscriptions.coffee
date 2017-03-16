AE = Artificial.Everywhere
PADB = PixelArtDatabase

# Returns the last themes to display on the homepage.
PADB.PixelDailies.Pages.Home.themes.publish (limit = 3) ->
  check limit, Number

  PADB.PixelDailies.Pages.Home.themes.query limit
