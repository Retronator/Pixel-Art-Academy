AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary
Action = LOI.Adventure.Ability.Action

class HQ.Items.Wallet extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Wallet'
  @url: -> 'signin'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "wallet"

  @shortName: -> "wallet"

  @description: ->
    "
      It's your wallet, very useful for holding your IDs. Use it at the reception desk to sign in.
    "

  @initialize()

  constructor: ->
    super

    @addAbility new Action
      verbs: [Vocabulary.Keys.Verbs.Use]
      action: =>
        location = @options.adventure.currentLocation()
        if location.id() is HQ.Locations.Reception.id()
          location.useWallet()
        
        else
          location.director().startScript location.scripts['Retronator.HQ.Items.Wallet.use']

  onCreated: ->
    super

    @loginButtonsSession = Accounts._loginButtonsSession

    # Keep sign in buttons always visible.
    @autorun (computation) =>
      dropdownVisible = @loginButtonsSession.get 'dropdownVisible'
      return if dropdownVisible

      @loginButtonsSession.set 'dropdownVisible', true

  inChangePasswordFlow: ->
    @loginButtonsSession.get 'inChangePasswordFlow'

  inMessageOnlyFlow: ->
    @loginButtonsSession.get 'inMessageOnlyFlow'

  onClickBackButtonHandler: ->
    => @onClickBackButton()

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
