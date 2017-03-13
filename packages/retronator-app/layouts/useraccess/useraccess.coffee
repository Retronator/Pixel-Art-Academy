RA = Retronator.App

class RA.Layouts.UserAccess extends BlazeLayoutComponent
  @register 'Retronator.App.Layouts.UserAccess'

  loading: ->
    Meteor.loggingIn()

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
