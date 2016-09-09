AM = Artificial.Mirage
LOI = LandsOfIllusions

# The singleton component that communicates to the accounts client.
class LOI.Accounts.Components.UserPanel extends AM.Component
  @register 'LandsOfIllusions.Accounts.Components.UserPanel'

  constructor: ->
    super

    @showPanel = new ReactiveField false

  landsOfIllusionsUrl: ->
    Meteor.settings.public.landsOfIllusionsUrl

  showCharacters: ->
    # We need to show characters if user needs to load one or
    # if there are more than 1 (so user can switch to another one).
    not LOI.characterId() or LOI.user().characters?.length > 1

  showCharacter: ->
    character = @currentData()

    # We show a character in the load list if it isn't the current one.
    character._id isnt LOI.characterId()

  events: ->
    super.concat
      'click .show-panel-button': @onClickShowPanelButton
      'click .close-panel-button': @onClickClosePanelButton
      'click .load-character': @onClickLoadCharacter

  onClickShowPanelButton: (event) ->
    @showPanel true

  onClickClosePanelButton: (event) ->
    @showPanel false

  onClickLoadCharacter: (event) ->
    character = @currentData()
    LOI.Accounts.switchCharacter character._id
    @showPanel false
