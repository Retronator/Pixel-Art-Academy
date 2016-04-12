AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Login extends AM.Component
  @register 'PixelArtAcademy.Pages.Login'

  onCreated: ->
    super

    # Redirect to account when sign in succeeded.
    @autorun =>
      FlowRouter.go 'home' if Meteor.userId() and Roles.userIsInRole Meteor.userId(), 'alpha-access'
