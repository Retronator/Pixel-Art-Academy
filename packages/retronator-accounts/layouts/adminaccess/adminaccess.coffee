RA = Retronator.Accounts

class RA.Layouts.AdminAccess extends BlazeLayoutComponent
  @register 'Retronator.Accounts.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
