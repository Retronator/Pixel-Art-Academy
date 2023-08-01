AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

Persistence = Artificial.Mummification.Document.Persistence

class LOI.Components.SaveGame extends AM.Component
  @id: -> 'LandsOfIllusions.Components.SaveGame'
  @register @id()

  @url: -> 'savegame'
  
  @version: -> '0.0.1'

  @initializeDataComponent()
  
  constructor: (@options) ->
    super arguments...
  
    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> [@activatable]
  
  onCreated: ->
    super arguments...

    @newSaveGameName = new ReactiveField null

  show: ->
    @newSaveGameName null

    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true

  onActivate: (finishedActivatingCallback) ->
    await _.waitForSeconds 0.5
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    await _.waitForSeconds 0.5
    finishedDeactivatingCallback()

  saveButtonVisibleClass: ->
    'visible' if @newSaveGameName()

  events: ->
    super(arguments...).concat
      'click .save-button': @onClickSaveButton

  onClickSaveButton: (event) ->
    LOI.adventure.saveGame local: true
    profileId = await LOI.adventure.profileId.waitForValue()

    Persistence.Profile.documents.update profileId,
      $set:
        displayName: @newSaveGameName()
        lastEditTime: new Date

    LOI.adventure.showDialogMessage "Your game is now auto-saving to this disk.", =>
      @callFirstWith null, 'deactivate'

  # Components

  class @NewSaveGameName extends @DataInputComponent
    @register 'LandsOfIllusions.Components.SaveGame.NewSaveGameName'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.TextArea
      @propertyName = 'newSaveGameName'

    placeholder: ->
      "Enter name"

    customAttributes: ->
      maxlength: 12 * 3
