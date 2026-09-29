AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.EditAssetsProvider extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.EditAssetsProvider'
  @register @id()

  @Modes =
    Creating: 'Creating'
    Naming: 'Naming'
    Editing: 'Editing'
    Duplicating: 'Duplicating'

  constructor: (@portfolio) ->
    super arguments...

    @assetsProvider = new ReactiveField null
    @thing = new ReactiveField null
    @mode = new ReactiveField null
    
    @creating = new ReactiveField false
    @visible = new ReactiveField false
    
  active: -> @mode()

  show: (assetsProvider, thing, mode) ->
    @assetsProvider assetsProvider
    @thing thing
    @mode mode
    
    Meteor.clearTimeout @_hideTimeout
    @visible true

  close: ->
    @assetsProvider null
    @thing null
    @mode null
    
    # Hiding happens with a 0.2s transition.
    @_hideTimeout = Meteor.setTimeout =>
      @visible false
    ,
      200

  onBackButton: ->
    return unless @active()

    @close()

    # Inform that we've handled the back button.
    true

  activeClass: ->
    'active' if @active()
    
  creatingClass: ->
    'creating' if @creating()
  
  labelCategory: -> @thing()?.assetsProviderLabelCategory()
  
  showEmptyName: ->
    @mode() in [@constructor.Modes.Creating, @constructor.Modes.Duplicating]

  assetsProviderNamePlaceholder: ->
    @thing()?.assetsProviderNamePlaceholder()

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .close-button': @onClickCloseButton
      'click .duplicate-button': @onClickDuplicateButton
      'click .delete-button': @onClickDeleteButton
      'click .confirm-duplicate-button': @onClickConfirmDuplicateButton
      'click .cancel-duplicate-button': @onClickCancelDuplicateButton
      'click .confirm-create-button': @onClickConfirmCreateButton

  onClick: (event) ->
    # Portfolio has a generic onClick that we have to prevent reaching when we interact with this dialog.
    event.stopPropagation()

  onClickCloseButton: (event) ->
    @close()

  onClickDuplicateButton: (event) ->
    @$('.name-area').scrollTop 0
    @mode @constructor.Modes.Duplicating

    Tracker.afterFlush => @$('.duplicate-name-input').focus()

  onClickDeleteButton: (event) ->
    thing = @thing()

    dialog = new LOI.Components.Dialog
      message: thing.deleteAssetsProviderConfirmation()
      buttons: [
        text: "Delete"
        value: true
      ,
        text: "Cancel"
      ]

    await LOI.adventure.showActivatableModalDialog {dialog}
    return unless dialog.result

    thing.deleteAssetsProvider @assetsProvider()
    @close()

  onClickConfirmDuplicateButton: (event) ->
    name = @$('.name textArea').val().trim()
    
    newAssetsProviderId = @thing().duplicateAssetsProvider @assetsProvider(), {name}
    @portfolio.selectAssetsProviderById newAssetsProviderId
    
    @close()

  onClickCancelDuplicateButton: (event) ->
    @$('.name-area').scrollTop 0
    @mode @constructor.Modes.Editing
    
  onClickConfirmCreateButton: (event) ->
    name = @$('.name textArea').val().trim()

    @creating true
    
    try
      await @thing().createAssetsProvider {name}
      
    finally
      @creating false
    
    @close()
    
  class @NameInput extends AM.DataInputComponent
    constructor: ->
      super arguments...

      @realtime = false
      @autoResizeTextarea = true
      @type = AM.DataInputComponent.Types.TextArea

    onCreated: ->
      super arguments...

      @editAssetsProvider = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Portfolio.EditAssetsProvider

    onRendered: ->
      super arguments...

      Tracker.afterFlush =>
        textArea = @$('textarea')[0]
        textArea.focus()
        textArea.setSelectionRange textArea.value.length, textArea.value.length

    placeholder: ->
      @editAssetsProvider.assetsProviderNamePlaceholder()

    customAttributes: ->
      maxlength: 15 * 3

  class @Name extends @NameInput
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.EditAssetsProvider.Name'

    load: ->
      assetsProvider = @data()
      assetsProvider.name()

    save: (value) ->
      assetsProvider = @data()
      assetsProvider.setName value
  
  class @EmptyName extends @NameInput
    @register 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.EditAssetsProvider.EmptyName'

    load: -> ''
    save: ->
