AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary
Action = LOI.Adventure.Ability.Action

class PAA.LandingPage.Items.About extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.LandingPage.Items.About'
  @url: -> 'about'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Retropolis Academy of Art prospectus"

  @shortName: -> "prespectus"

  @description: ->
    "
      It's a pamphlet about the game called Pixel Art Academy.
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

  events: ->
    super.concat
      'click #login-buttons-logout': @onClickLogoutButton

  onClickLogoutButton: (event) ->
    Meteor.logout()
