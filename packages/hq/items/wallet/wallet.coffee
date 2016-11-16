AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Wallet extends LOI.Adventure.Item
  @register 'Retronator.HQ.Items.Wallet'
  template: -> 'Retronator.HQ.Items.Wallet'

  @id: -> 'Retronator.HQ.Items.Wallet'
  @url: -> 'signin'

  @fullName: -> "wallet"

  @shortName: -> "wallet"

  @description: ->
    "
      It's your wallet, very useful for holding your IDs. Use it at the reception desk to sign in.
    "

  @initialize()

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

  events: ->
    super.concat
      'click #login-buttons-logout': @onClickLogoutButton
