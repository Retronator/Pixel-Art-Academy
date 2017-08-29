AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Construct.Loading.TV.NewLink extends AM.Component
  @register 'LandsOfIllusions.Construct.Loading.TV.NewLink'

  constructor: (@tv) ->
    super

  onCreated: ->
    super

    # Subscribe to pre-made characters.
    LOI.Construct.Loading.PreMadeCharacter.all.subscribe @

    @preMadeCharacters = new ComputedField =>
      LOI.Construct.Loading.PreMadeCharacter.documents.find().fetch()

    @currentPreMadeCharacterIndex = new ReactiveField 0

    @currentPreMadeCharacter = new ComputedField =>
      @preMadeCharacters()[@currentPreMadeCharacterIndex()]

    @currentCharacter = new ComputedField =>
      return unless characterId = @currentPreMadeCharacter()?.character._id

      LOI.Character.forId.subscribe @, characterId

      return unless characterDocument = LOI.Character.documents.findOne characterId
      
      new LOI.Character.Instance characterDocument._id

  backButtonCallback: ->
    # We return to main menu.
    @_returnToMenu()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  _returnToMenu: ->
    @tv.switchToScreen @tv.screens.mainMenu

  events: ->
    super.concat
      'click .clone-character-button': @onClickCloneCharacterButton
      'click .cancel-button': @onClickCancelButton
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickCloneCharacterButton: (event) ->
    LOI.Construct.Loading.PreMadeCharacter.cloneToCurrentUser @currentPreMadeCharacter()._id
    @_returnToMenu()

  onClickCancelButton: (event) ->
    @_returnToMenu()

  onClickPreviousButton: (event) ->
    newIndex = @currentPreMadeCharacterIndex() - 1
    newIndex = @preMadeCharacters().length - 1 if newIndex < 0

    @currentPreMadeCharacterIndex newIndex

  onClickNextButton: (event) ->
    newIndex = @currentPreMadeCharacterIndex() + 1
    newIndex = 0 if newIndex >= @preMadeCharacters().length

    @currentPreMadeCharacterIndex newIndex
