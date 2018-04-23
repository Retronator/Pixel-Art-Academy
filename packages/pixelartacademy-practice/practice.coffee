PAA = PixelArtAcademy

class PAA.Practice
  constructor: ->
    Retronator.App.addAdminPage '/admin/practice', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/practice/scripts', @constructor.Pages.Admin.Scripts
