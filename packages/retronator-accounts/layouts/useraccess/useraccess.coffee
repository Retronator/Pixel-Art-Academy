RA = Retronator.Accounts

class RA.Layouts.UserAccess extends BlazeLayoutComponent
  @register 'Retronator.Accounts.Layouts.UserAccess'

  loading: ->
    Meteor.loggingIn()

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
