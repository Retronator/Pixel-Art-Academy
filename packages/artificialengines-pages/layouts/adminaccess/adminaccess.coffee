class Artificial.Pages.Layouts.AdminAccess extends BlazeComponent
  @register 'Artificial.Pages.Layouts.AdminAccess'

  onCreated: ->
    super arguments...
    
    Meteor.reconnect()
  
  loading: ->
    Meteor.loggingIn()
