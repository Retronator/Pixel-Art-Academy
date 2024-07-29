AB = Artificial.Babel
AC = Artificial.Control
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions

Persistence = Artificial.Mummification.Document.Persistence

class LOI.Components.SaveGame extends LOI.Component
  @id: -> 'LandsOfIllusions.Components.SaveGame'
  @register @id()

  @url: -> 'savegame'
  
  @version: -> '0.0.1'

  @initializeDataComponent()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      save: AEc.ValueTypes.Boolean
      
  constructor: (@options) ->
    super arguments...
  
    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> super(arguments...).concat @activatable
  
  onCreated: ->
    super arguments...

    @newSaveGameName = new ReactiveField null
    @savingActive = new ReactiveField false

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
    @savingActive false
    finishedDeactivatingCallback()

  saveButtonVisibleClass: ->
    'visible' if @newSaveGameName()
    
  savingActiveClass: ->
    'saving-active' if @savingActive()

  events: ->
    super(arguments...).concat
      'click .save-button': @onClickSaveButton

  onClickSaveButton: (event) ->
    @audio.save true
    @savingActive true
  
    LOI.adventure.saveGame local: true

    # Wait for animation of the floppy.
    await _.waitForSeconds 0.5

    profileId = await LOI.adventure.profileId.waitForValue()

    Persistence.Profile.documents.update profileId,
      $set:
        displayName: @newSaveGameName()
        lastEditTime: new Date

    LOI.adventure.showDialogMessage "Your game will be automatically saving to this disk.", =>
      @audio.save false
      
      @callFirstWith null, 'deactivate'

  # Components

  class @NewSaveGameName extends @DataInputComponent
    @register 'LandsOfIllusions.Components.SaveGame.NewSaveGameName'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.TextArea
      @propertyName = 'newSaveGameName'
      
    onRendered: ->
      super arguments...
      
      @$('textarea').focus()

    placeholder: ->
      "Enter name"

    customAttributes: ->
      maxlength: 12 * 3
