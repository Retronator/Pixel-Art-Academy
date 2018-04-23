AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Service.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Service.Terminal.MainMenu'

  constructor: (@terminal) ->

  onCreated: ->
    super
    
    @_characters = []
      
    @characters = new ComputedField =>
      character.destroy() for character in @_characters

      user = Retronator.user()

      designedCharacters = _.filter user.characters, (character) =>
        LOI.Character.documents.findOne(character._id)?.designApproved

      @_characters = for character in designedCharacters
        Tracker.nonreactive =>
          new LOI.Character.Instance character._id

      @_characters
      
    @newCharacterMade = false

  events: ->
    super.concat
      'click .character-selection-button': @onClickCharacterSelectionButton
      'click .new-character-button': @onClickNewCharacterButton

  onClickCharacterSelectionButton: (event) ->
    characterInstance = @currentData()

    @terminal.screens.character.setCharacterId characterInstance._id
    @terminal.switchToScreen @terminal.screens.character

  onClickNewCharacterButton: (event) ->
    @terminal.switchToScreen @terminal.screens.modelSelection
