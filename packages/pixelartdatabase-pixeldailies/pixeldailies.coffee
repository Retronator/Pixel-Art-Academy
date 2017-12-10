AM = Artificial.Mirage
AB = Artificial.Base
PADB = PixelArtDatabase

class PADB.PixelDailies
  constructor: ->
    AB.Router.addRoute '/pixeldailies', @constructor.Pages.Home.Layout, @constructor.Pages.Home
    AB.Router.addRoute '/pixeldailies/about', @constructor.Pages.Home.Layout, @constructor.Pages.About

    @_addYearReviewPage '/pixeldailies/:year/artworks', @constructor.Pages.YearReview.Artworks
    @_addYearReviewPage '/pixeldailies/:year/artists', @constructor.Pages.YearReview.Artists
    @_addYearReviewPage '/pixeldailies/:year/about', @constructor.Pages.YearReview.About
    @_addYearReviewPage '/pixeldailies/:year/user/:screenName', @constructor.Pages.YearReview.Artist
    @_addYearReviewPage '/pixeldailies/:year/:month?/:day?', @constructor.Pages.YearReview.Day

    Retronator.App.addAdminPage '/admin/pixeldailies', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/pixeldailies/scripts', @constructor.Pages.Admin.Scripts

  _addYearReviewPage: (url, pageClass) ->
    AB.Router.addRoute url, @constructor.Pages.YearReview.Layout, pageClass
