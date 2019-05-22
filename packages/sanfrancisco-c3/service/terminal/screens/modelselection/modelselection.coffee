AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Service.Terminal.ModelSelection extends AM.Component
  @register 'SanFrancisco.C3.Service.Terminal.ModelSelection'

  constructor: (@terminal) ->
    super arguments...
    
  onCreated: ->
    super arguments...

    # Subscribe to pre-made characters.
    LOI.Character.PreMadeCharacter.all.subscribe @

    @preMadeCharacters = new ComputedField =>
      LOI.Character.PreMadeCharacter.documents.find().fetch()

    @characters = new ComputedField =>
      LOI.Character.getInstance preMadeCharacter.character._id for preMadeCharacter in @preMadeCharacters()

    @currentPreMadeCharacterIndex = new ReactiveField 0

    @currentPreMadeCharacter = new ComputedField =>
      @preMadeCharacters()[@currentPreMadeCharacterIndex()]

    @currentCharacter = new ComputedField =>
      @characters()[@currentPreMadeCharacterIndex()]

    @cloningCharacter = new ReactiveField false

    AB.subscribeNamespace 'LandsOfIllusions.Character.Behavior.Perk', subscribeProvider: @

    @_initialPreviewViewingAngle = -Math.PI / 4
    @previewViewingAngle = new ReactiveField @_initialPreviewViewingAngle

  backButtonCallback: ->
    # We return to main menu.
    @_returnToMenu()

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  noName: ->
    LOI.Character.Avatar.noNameTranslation()

  traits: ->
    @currentCharacter()?.behavior.part.properties.personality.part.traitsString() or "None"

  activities: ->
    @currentCharacter()?.behavior.part.properties.activities.toString() or "None"

  environment: ->
    @currentCharacter()?.behavior.part.properties.environment.part

  perks: ->
    @currentCharacter()?.behavior.part.properties.perks.toString() or "None"

  avatarPreviewOptions: ->
    rotatable: true
    viewingAngle: @previewViewingAngle
    originOffset:
      x: -3
      y: 8

  events: ->
    super(arguments...).concat
      'click .clone-character-button': @onClickCloneCharacterButton
      'click .cancel-button': @onClickCancelButton
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton
      'click .confirm-clone-button': @onClickConfirmCloneButton
      'click .cancel-clone-button': @onClickCancelCloneButton

  onClickCloneCharacterButton: (event) ->
    @cloningCharacter true

  onClickConfirmCloneButton: (event) ->
    name = @$('.name-input').val()
    LOI.Character.PreMadeCharacter.cloneToCurrentUser @currentPreMadeCharacter()._id, name
    @_returnToMenu()

    @terminal.createdCharacter = true

  onClickCancelCloneButton: (event) ->
    @cloningCharacter false

  onClickCancelButton: (event) ->
    @_returnToMenu()

  onClickPreviousButton: (event) ->
    newIndex = @currentPreMadeCharacterIndex() - 1
    newIndex = @preMadeCharacters().length - 1 if newIndex < 0

    @_selectCharacter newIndex

  onClickNextButton: (event) ->
    newIndex = @currentPreMadeCharacterIndex() + 1
    newIndex = 0 if newIndex >= @preMadeCharacters().length

    @_selectCharacter newIndex

  _selectCharacter: (index) ->
    # Reset viewing angle.
    @previewViewingAngle @_initialPreviewViewingAngle
    @currentPreMadeCharacterIndex index

  _returnToMenu: ->
    @terminal.switchToScreen @terminal.screens.mainMenu
