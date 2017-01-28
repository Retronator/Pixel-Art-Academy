AT = Artificial.Telepathy

class Retronator.Accounts
  constructor: ->
    Retronator.App.addAdminPage '/admin/accounts', 'Retronator.Accounts.Pages.Admin'
    Retronator.App.addAdminPage '/admin/accounts/import-users', 'Retronator.Accounts.Pages.Admin.ImportUsers'
    Retronator.App.addAdminPage '/admin/accounts/scripts', 'Retronator.Accounts.Pages.Admin.Scripts'

  @authorizeAdmin: ->
    user = Retronator.user()

    return if user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

    throw new AE.UnauthorizedException "You do not have administrator privileges to perform this action."
