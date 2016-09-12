AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Construct.Pages.Login extends AM.Component
  @register 'LandsOfIllusions.Construct.Pages.Login'

  onCreated: ->
    super

    # Redirect to account when sign in succeeded.
    @autorun =>
      FlowRouter.go 'LandsOfIllusions.Start' if Meteor.userId()

  onDestroyed: ->
    super
