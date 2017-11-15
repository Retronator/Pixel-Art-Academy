class Retronator.Store
  constructor: ->
    Retronator.App.addAdminPage '/admin/store', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/store/scripts', @constructor.Pages.Admin.Scripts
    Retronator.App.addAdminPage '/admin/store/authorized-payments', @constructor.Pages.Admin.AuthorizedPayments
