AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Environment extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Environment'

  constructor: (@terminal) ->

  onCreated: ->
    super

    @part = new ReactiveField null
    @behaviorPart = new ReactiveField null

    # Get the environment from the character.
    @autorun (computation) =>
      behaviorPart = @terminal.screens.character.character()?.behavior.part
      @behaviorPart behaviorPart

      environmentPart = behaviorPart.properties.environment
      @part environmentPart

  backButtonCallback: ->
    @closeScreen()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  closeScreen: ->
    @terminal.switchToScreen @terminal.screens.character

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton
      'click .modify-people-button': @onClickModifyPeopleButton

  onClickDoneButton: (event) ->
    @closeScreen()

  onClickModifyPeopleButton: (event) ->
    @terminal.switchToScreen @terminal.screens.people
