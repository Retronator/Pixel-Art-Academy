RA = Retronator.Accounts

class RA.Layouts.Store extends BlazeLayoutComponent
  @register 'Retronator.Accounts.Layouts.PublicAccess'

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
