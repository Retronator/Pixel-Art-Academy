AM = Artificial.Mirage
AT = Artificial.Telepathy
PADB = PixelArtDatabase

class PADB.PixelDailies
  constructor: ->
    Retronator.App.addPublicPage '/pixeldailies', 'PixelArtDatabase.PixelDailies.Pages.Home'

    @_addYearReviewPage '/pixeldailies/:year/artworks', 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artworks'
    @_addYearReviewPage '/pixeldailies/:year/user/:screenName', 'PixelArtDatabase.PixelDailies.Pages.YearReview.Artist'
    @_addYearReviewPage '/pixeldailies/:year/:month?/:day?', 'PixelArtDatabase.PixelDailies.Pages.YearReview.Day'

    Retronator.App.addAdminPage '/admin/pixeldailies', 'PixelArtDatabase.PixelDailies.Pages.Admin'
    Retronator.App.addAdminPage '/admin/pixeldailies/scripts', 'PixelArtDatabase.PixelDailies.Pages.Admin.Scripts'

  _addYearReviewPage: (url, page) ->
    AT.addRoute page, url, 'PixelArtDatabase.PixelDailies.Pages.YearReview.Layout', page
