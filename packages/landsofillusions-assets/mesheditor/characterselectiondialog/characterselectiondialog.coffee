AE = Artificial.Everywhere
AM = Artificial.Mirage
AR = Artificial.Reality
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CharacterSelectionDialog extends FM.View
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.CharacterSelectionDialog'
  @register @id()

  onCreated: ->
    super arguments...

    LOI.Character.forCurrentUser.subscribe()

    @selectedCharacterId = new ReactiveField null

  closeDialog: ->
    dialogData = @ancestorComponentOfType(FM.FloatingArea).data()
    @interface.closeDialog dialogData

  characters: ->
    LOI.Character.documents.find()

  selectedClass: ->
    character = @currentData()
    'selected' if character._id is @selectedCharacterId()

  selectButtonDisabledAttribute: ->
    disabled: true unless @selectedCharacterId()

  _completeSelection: (characterId) ->
    characterPreviewHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CharacterPreview
    characterPreviewHelper.setCharacterId characterId

    @closeDialog()

  events: ->
    super(arguments...).concat
      'click .character': @onClickCharacter
      'dblclick .character': @onDoubleClickCharacter
      'click .cancel-button': @onClickCancelButton
      'click .select-button': @onClickSelectButton

  onClickCharacter: (event) ->
    character = @currentData()
    @selectedCharacterId character._id

  onDoubleClickCharacter: (event) ->
    character = @currentData()
    @_completeSelection character._id

  onClickCancelButton: (event) ->
    @closeDialog()

  onClickSelectButton: (event) ->
    @_completeSelection @selectedCharacterId()
