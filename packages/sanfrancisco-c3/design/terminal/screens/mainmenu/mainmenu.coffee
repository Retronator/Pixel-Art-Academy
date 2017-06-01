AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.MainMenu'

  constructor: (@terminal) ->

  onCreated: ->
    super

  character: ->
    character = @currentData()

    new LOI.Character.Instance character._id

  events: ->
    super.concat
      'click .character-selection-button': @onClickCharacterSelectionButton

  onClickCharacterSelectionButton: (event) ->
    characterInstance = @currentData()

    @terminal.screens.character.setCharacterId characterInstance.id
    @terminal.switchToScreen @terminal.screens.character
