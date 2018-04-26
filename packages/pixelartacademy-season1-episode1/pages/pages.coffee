E1 = PixelArtAcademy.Season1.Episode1

class E1.Pages
  constructor: ->
    Retronator.App.addAdminPage '/admin/episode1', @constructor.Admin
    Retronator.App.addAdminPage '/admin/episode1/admissions', @constructor.Admin.Admissions
