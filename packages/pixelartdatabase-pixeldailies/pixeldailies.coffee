AM = Artificial.Mirage
AT = Artificial.Telepathy
PADB = PixelArtDatabase

class PADB.PixelDailies
  constructor: ->
    Retronator.App.addPublicPage '/pixeldailies', 'PixelArtDatabase.PixelDailies.Pages.Home'

    @_addTop2016Page '/pixeldailies/top2016', 'PixelArtDatabase.PixelDailies.Pages.Top2016'
    @_addTop2016Page '/pixeldailies/top2016/artworks', 'PixelArtDatabase.PixelDailies.Pages.Top2016.Artworks'

    Retronator.App.addAdminPage '/admin/pixeldailies', 'PixelArtDatabase.PixelDailies.Pages.Admin'
    Retronator.App.addAdminPage '/admin/pixeldailies/scripts', 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts'

  _addTop2016Page: (url, page) ->
    AT.addRoute page, url, 'PixelArtDatabase.PixelDailies.Pages.Top2016.Layout', page
