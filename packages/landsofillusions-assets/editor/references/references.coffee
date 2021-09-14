AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.References extends FM.View
  # activeReferenceIndex: the index of the selected reference
  @id: -> 'LandsOfIllusions.Assets.Editor.References'
  @register @id()

  onCreated: ->
    super arguments...

    @assetData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()

    @references = new ComputedField =>
      # Attach indices to references.
      for reference, index in @assetData()?.references or []
        _.extend _.clone(reference), {index}

    @activeReferencesData = new ComputedField =>
      @interface.getComponentDataForActiveFile @

    @displayModeTexts =
      EmbeddedUnder: 'Embedded under'
      EmbeddedOver: 'Embedded over'
      FloatingInside: 'Floating inside'
      FloatingOutside: 'Floating outside'

    @displayModes = ({value, text} for value, text of @displayModeTexts)

  activeClass: ->
    reference = @currentData()
    'active' if reference.index is @activeReferencesData()?.get 'activeReferenceIndex'

  displayedCheckedAttribute: ->
    reference = @currentData()
    'checked' if reference.displayed ? true

  displayModeSelectedAttribute: ->
    displayMode = @currentData()
    reference = Template.parentData()

    'selected' if reference.displayMode is displayMode.value

  showRemoveButton: ->
    # We can remove a reference if one is active.
    @activeReferencesData()?.get('activeReferenceIndex')?

  # Events

  events: ->
    super(arguments...).concat
      'click .reference': @onClickReference
      'change .displayed-checkbox': @onChangeDisplayedCheckbox
      'change .display-mode-select': @onChangeDisplayModeSelect
      'click .upload-button': @onClickUploadButton
      'click .remove-button': @onClickRemoveButton

  onClickReference: (event) ->
    reference = @currentData()
    @activeReferencesData()?.set 'activeReferenceIndex', reference.index

  onChangeDisplayedCheckbox: (event) ->
    reference = @currentData()
    assetData = @assetData()

    checked = $(event.target).is(':checked')
    LOI.Assets.VisualAsset.updateReferenceDisplayed assetData.constructor.className, assetData._id, reference.image._id, checked

  onChangeDisplayModeSelect: (event) ->
    reference = @currentData()
    assetData = @assetData()

    displayMode = $(event.target).val()
    LOI.Assets.VisualAsset.updateReferenceDisplayMode assetData.constructor.className, assetData._id, reference.image._id, displayMode

  onClickUploadButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      LOI.Assets.Components.References.referenceUploadContext.upload file, (url) =>
        # Add reference to asset.
        assetData = @assetData()
        LOI.Assets.VisualAsset.addReferenceByUrl assetData.constructor.className, assetData._id, null, url

    $fileInput.click()

  onClickRemoveButton: (event) ->
    activeReferenceIndex = @activeReferencesData()?.get 'activeReferenceIndex'
    reference = @assetData()?.references[activeReferenceIndex]

    assetData = @assetData()

    LOI.Assets.VisualAsset.removeReference assetData.constructor.className, assetData._id, reference.image._id
