class Retronator.Store
  constructor: ->
    Retronator.App.addAdminPage '/admin/store', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/store/scripts', @constructor.Pages.Admin.Scripts
    Retronator.App.addAdminPage '/admin/store/authorized-payments', @constructor.Pages.Admin.AuthorizedPayments
    Retronator.App.addAdminPage '/admin/store/patreon', @constructor.Pages.Admin.Patreon
    Retronator.App.addAdminPage '/admin/store/vat', @constructor.Pages.Admin.Vat
    Retronator.App.addAdminPage '/admin/store/transactions', @constructor.Pages.Admin.Transactions
    Retronator.App.addAdminPage '/admin/store/payments', @constructor.Pages.Admin.Payments
    Retronator.App.addAdminPage '/admin/store/item-keys', @constructor.Pages.Admin.ItemKeys

    Retronator.App.addPublicPage 'retronator.com/store/invoice/:accessSecret', @constructor.Pages.Invoice
