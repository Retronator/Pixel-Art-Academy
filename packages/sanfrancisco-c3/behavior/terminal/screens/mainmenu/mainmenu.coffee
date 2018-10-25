AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.MainMenu'

  constructor: (@terminal) ->
    super arguments...

  onCreated: ->
    super arguments...
    
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

  events: ->
    super(arguments...).concat
      'click .character-selection-button': @onClickCharacterSelectionButton

  onClickCharacterSelectionButton: (event) ->
    characterInstance = @currentData()

    @terminal.screens.character.setCharacterId characterInstance._id
    @terminal.switchToScreen @terminal.screens.character
