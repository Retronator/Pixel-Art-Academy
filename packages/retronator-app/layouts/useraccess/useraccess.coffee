RA = Retronator.App

class RA.Layouts.UserAccess extends BlazeComponent
  @register 'Retronator.App.Layouts.UserAccess'

  loading: ->
    Meteor.loggingIn()
