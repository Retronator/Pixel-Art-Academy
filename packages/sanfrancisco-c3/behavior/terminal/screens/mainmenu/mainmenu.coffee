AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.MainMenu'

  constructor: (@terminal) ->

  onCreated: ->
    super

  designedCharacters: ->
    user = Retronator.user()

    _.filter user.characters, (character) =>
      LOI.Character.documents.findOne(character._id)?.designApproved

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
