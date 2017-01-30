AE = Artificial.Everywhere

class Retronator.Accounts
  constructor: ->
    Retronator.App.addAdminPage '/admin/accounts', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/accounts/import-users', @constructor.Pages.Admin.ImportUsers
    Retronator.App.addAdminPage '/admin/accounts/scripts', @constructor.Pages.Admin.Scripts

  @authorizeAdmin: ->
    user = Retronator.user()

    return if user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

    throw new AE.UnauthorizedException "You do not have administrator privileges to perform this action."
