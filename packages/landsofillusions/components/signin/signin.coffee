AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.SignIn extends AM.Component
  @register 'LandsOfIllusions.Components.SignIn'
  @url: -> 'signin'

  @version: -> '0.0.1'

  constructor: (@options) ->
    super

    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> [@activatable]

  onCreated: ->
    super

    @loginButtonsSession = Accounts._loginButtonsSession

    # Keep login buttons always visible (we need to override its default dropdown behavior).
    @autorun (computation) =>
      dropdownVisible = @loginButtonsSession.get 'dropdownVisible'
      return if dropdownVisible

      @loginButtonsSession.set 'dropdownVisible', true

  inChangePasswordFlow: ->
    @loginButtonsSession.get 'inChangePasswordFlow'

  inMessageOnlyFlow: ->
    @loginButtonsSession.get 'inMessageOnlyFlow'

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  events: ->
    super.concat
      'click #login-buttons-logout': @onClickLogoutButton

  onClickLogoutButton: (event) ->
    @options.adventure.logout()
