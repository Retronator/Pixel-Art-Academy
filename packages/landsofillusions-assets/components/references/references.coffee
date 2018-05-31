AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.References extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.References'

  @register @id()
  template: -> @constructor.id()

  @referenceUploadContext = new LOI.Assets.Upload.Context
    name: "#{@id()}.reference"
    folder: 'references'
    maxSize: 10 * 1024 * 1024 # 10 MB
    fileTypes: [
      'image/png'
      'image/jpeg'
      'image/gif'
    ]
    
  constructor: (@options) ->
    super

    @draggingReference = new ReactiveField null
    @draggingDisplayed = new ReactiveField false

  onCreated: ->
    super

    @display = @callAncestorWith 'display'

    @assetData = new ComputedField =>
      assetId = @options.assetId()
      @options.documentClass.documents.findOne assetId,
        fields:
          references: 1
          
    @uploadingReferences = new ReactiveField []
    
    @references = new ComputedField =>
      return [] unless assetData = @assetData()

      # Reuse image ID on asset to minimize reactivity.
      assetReferences = _.cloneDeep(assetData.references) or []
      assetReference._id = assetReference.image._id for assetReference in assetReferences

      uploadingReferences = @uploadingReferences()

      # Merge existing and uploading references.
      [assetReferences..., uploadingReferences...]

  removeUploadingReference: (referenceId, imageId) ->
    # Wait until references have updated and we have the new one with created image ID.
    @autorun (computation) =>
      # Make sure the component has finished loading the image, to prevent flickering.
      loadedComponents = @childComponentsWith (component) =>
        component.data().image?._id is imageId and component.size()

      return unless loadedComponents.length
      computation.stop()

      uploadingReferences = @uploadingReferences()
      _.remove uploadingReferences, (uploadingReference) => uploadingReference._id is referenceId

      @uploadingReferences uploadingReferences
      
  startDrag: (options) ->
    @dragStartMousePosition = options.mouseCoordinate
    @dragStartReferencePosition = options.referencePosition

    @dragDelta =
      x: 0
      y: 0

    options.reference.draggingPosition @dragStartReferencePosition

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on "mouseup.landsofillusions-assets-components-references", (event) =>
      $(document).off '.landsofillusions-assets-components-references'

      # Make sure we still have the reference in case of recomputation during drag.
      return unless draggingReference = @draggingReference()
      draggingReference.endDrag()

      @draggingReference null

    $(document).on "mousemove.landsofillusions-assets-components-references", (event) =>
      draggingReference = @draggingReference()

      scale = @display.scale()

      @dragDelta =
        x: (event.pageX - @dragStartMousePosition.x) / scale
        y: (event.pageY - @dragStartMousePosition.y) / scale

      draggingReference.draggingPosition
        x: @dragStartReferencePosition.x + @dragDelta.x
        y: @dragStartReferencePosition.y + @dragDelta.y

    # Set goal component last since it triggers reactivity.
    @draggingReference options.reference

  storedReferences: -> _.filter @references(), (reference) => not _.propertyValue reference, 'displayed'
  displayedReferences: -> _.filter @references(), (reference) => _.propertyValue reference, 'displayed'

  styleClasses: -> '' # Overrdide to provide custom style classes
  
  dragging: ->
    @draggingReference()?

  events: ->
    super.concat
      'click .upload-button': @onClickUploadButton
      'click .storage-button': @onClickStorageButton

  onClickUploadButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      uploadingReferences = @uploadingReferences()

      uploadingReferences.push
        _id: Random.id()
        file: file
        # We create reactive values for uploading references so they can be updated reactively.
        position: new ReactiveField x: 0, y: 0
        scale: new ReactiveField null
        displayed: new ReactiveField false
        preview: new ReactiveField null

      @uploadingReferences uploadingReferences

    $fileInput.click()

  onClickStorageButton: (event) ->
    # TODO
