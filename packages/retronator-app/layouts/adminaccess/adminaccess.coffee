RA = Retronator.App

class RA.Layouts.AdminAccess extends BlazeComponent
  @register 'Retronator.App.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()
