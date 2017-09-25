class Retronator.Store
  constructor: ->
    Retronator.App.addAdminPage '/admin/store', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/store/scripts', @constructor.Pages.Admin.Scripts
