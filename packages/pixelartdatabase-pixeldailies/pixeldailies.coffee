AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies
  constructor: ->
    Retronator.App.addPublicPage '/pixeldailies', 'PixelArtDatabase.PixelDailies.Pages.Home'

    Retronator.App.addPublicPage '/pixeldailies/top2016/artworks', 'PixelArtDatabase.PixelDailies.Pages.Top2016.Artworks'

    Retronator.App.addAdminPage '/admin/pixeldailies', 'PixelArtDatabase.PixelDailies.Pages.Admin'
    Retronator.App.addAdminPage '/admin/pixeldailies/scripts', 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts'
