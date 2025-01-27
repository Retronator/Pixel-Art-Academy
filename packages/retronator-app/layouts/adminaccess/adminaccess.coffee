RA = Retronator.App

class RA.Layouts.AdminAccess extends BlazeComponent
  @register 'Retronator.App.Layouts.AdminAccess'

  onCreated: ->
    super arguments...
    
    Meteor.reconnect()
    
  loading: ->
    Meteor.loggingIn()
