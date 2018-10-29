AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.MainMenu'

  constructor: (@terminal) ->
    super arguments...

  onCreated: ->
    super arguments...

  character: ->
    character = @currentData()

    new LOI.Character.Instance character._id

  events: ->
    super(arguments...).concat
      'click .character-selection-button': @onClickCharacterSelectionButton
      'click .new-character-button': @onClickNewCharacterButton

  onClickCharacterSelectionButton: (event) ->
    characterInstance = @currentData()

    @terminal.screens.character.setCharacterId characterInstance._id
    @terminal.switchToScreen @terminal.screens.character

  onClickNewCharacterButton: (event) ->
    LOI.Character.insert (error, characterId) =>
      if error
        console.error error
        return

      @terminal.screens.character.setCharacterId characterId
      @terminal.switchToScreen @terminal.screens.character
