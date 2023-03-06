AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.SignIn extends AM.Component
  @register 'LandsOfIllusions.Components.SignIn'
  @url: -> 'signin'

  @version: -> '0.0.2'

  constructor: (@options) ->
    super arguments...

    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> [@activatable]

  onCreated: ->
    super arguments...

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

  message: ->
    @loginButtonsSession.get('infoMessage') or @loginButtonsSession.get('errorMessage')

  messageClass: ->
    return 'info' if @loginButtonsSession.get 'infoMessage'
    return 'error' if @loginButtonsSession.get 'errorMessage'

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
