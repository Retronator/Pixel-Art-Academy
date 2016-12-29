class Retronator.Store
  constructor: ->
    Retronator.Accounts.addAdminPage '/admin/store', 'Retronator.Store.Pages.Admin'
    Retronator.Accounts.addAdminPage '/admin/store/scripts', 'Retronator.Store.Pages.Admin.Scripts'
