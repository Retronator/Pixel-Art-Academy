class Artificial.Pages.Layouts.AdminAccess extends BlazeComponent
  @register 'Artificial.Pages.Layouts.AdminAccess'

  loading: ->
    Meteor.loggingIn()
