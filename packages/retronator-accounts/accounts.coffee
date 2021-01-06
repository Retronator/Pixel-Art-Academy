AE = Artificial.Everywhere

# We need to save Meteor's Accounts since defining a class with the same name will overwrite it in this scope.
AccountsMeteor = Accounts

class Retronator.Accounts
  constructor: ->
    Retronator.App.addAdminPage '/admin/accounts', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/accounts/import-users', @constructor.Pages.Admin.ImportUsers
    Retronator.App.addAdminPage '/admin/accounts/scripts', @constructor.Pages.Admin.Scripts

  @authorizeAdmin: (options) ->
    user = Retronator.requireUser options

    return if user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

    throw new AE.UnauthorizedException "You do not have administrator privileges to perform this action."

  @clearLoginInformation: ->
    AccountsMeteor._unstoreLoginToken()
    localStorage.removeItem 'Meteor.loginToken'
    localStorage.removeItem 'Meteor.loginTokenExpires'
