AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.MainMenu extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.MainMenu'

  constructor: (@terminal) ->
    super arguments...

  onCreated: ->
    super arguments...
    
    @characters = new ComputedField =>
      return unless characters = Retronator.user()?.characters

      characters = for character in characters
        LOI.Character.documents.findOne
          _id: character._id
          designApproved: true

      _.pull characters, undefined

      for character in characters
        character.translatedName = AB.translate(character.avatar.fullName).text

      _.sortBy characters, 'translatedName'

  events: ->
    super(arguments...).concat
      'click .character-selection-button': @onClickCharacterSelectionButton

  onClickCharacterSelectionButton: (event) ->
    characterInstance = @currentData()

    @terminal.screens.character.setCharacterId characterInstance._id
    @terminal.switchToScreen @terminal.screens.character
