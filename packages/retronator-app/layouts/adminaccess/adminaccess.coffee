RA = Retronator.App

class RA.Layouts.AdminAccess extends BlazeLayoutComponent
  @register 'Retronator.App.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
