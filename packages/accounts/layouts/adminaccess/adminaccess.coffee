RA = Retronator.Accounts

class RA.Layouts.AdminAccess extends BlazeLayoutComponent
  @register 'Retronator.Accounts.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()

  characters: ->
    user = Retronator.Accounts.User.documents.findOne Meteor.userId(),
      fields:
        landsOfIllusions:
          characters: 1

    user?.characters

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent
