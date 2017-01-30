RA = Retronator.App

class RA.Layouts.PublicAccess extends BlazeLayoutComponent
  @register 'Retronator.App.Layouts.PublicAccess'

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
