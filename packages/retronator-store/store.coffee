class Retronator.Store
  constructor: ->
    Retronator.App.addAdminPage '/admin/store', 'Retronator.Store.Pages.Admin'
    Retronator.App.addAdminPage '/admin/store/scripts', 'Retronator.Store.Pages.Admin.Scripts'
