AT = Artificial.Telepathy

class Retronator.Accounts
  constructor: ->
    Retronator.Accounts.addAdminPage 'LandsOfIllusions.Admin', '/admin/accounts', 'Retronator.Accounts.Pages.Admin'
    Retronator.Accounts.addAdminPage 'LandsOfIllusions.ImportUsers', '/admin/accounts/import-users', 'Retronator.Accounts.Pages.Admin.ImportUsers'
    Retronator.Accounts.addAdminPage 'LandsOfIllusions.Scripts', '/admin/accounts/scripts', 'Retronator.Accounts.Pages.Admin.Scripts'

  # Routing helpers for default layouts

  @addPublicPage: (name, url, page) ->
    AT.addRoute name, url, 'Retronator.Accounts.Layouts.PublicAccess', page

  @addUserPage: (name, url, page) ->
    AT.addRoute name, url, 'Retronator.Accounts.Layouts.UserAccess', page

  @addAdminPage: (name, url, page) ->
    AT.addRoute name, url, 'Retronator.Accounts.Layouts.AdminAccess', page
