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
    fileTypes: LOI.Assets.Upload.Context.FileTypes.Images
    
  constructor: (@options) ->
    super arguments...
        
    @draggingReference = new ReactiveField null
    @draggingDisplayed = new ReactiveField false

    # Override to provide a custom scaling factor for dragging.
    @draggingScale = => 1

    @resizingReference = new ReactiveField null

  onCreated: ->
    super arguments...

    @display = @callAncestorWith 'display'

    if @options.assetData
      @assetData = new ComputedField =>
        # Strip data to references and ID to minimize reactivity, but keep the class reference.
        return unless assetData = @options.assetData()
        strippedAssetData = _.pick assetData, ['references', '_id']
        Object.setPrototypeOf strippedAssetData, assetData.constructor.prototype
        strippedAssetData
      ,
        EJSON.equals

    else
      @assetData = new ComputedField =>
        assetId = @options.assetId()
        @options.documentClass.documents.findOne assetId,
          fields:
            references: 1

    @assetId = new ComputedField =>
      @options.assetId?() or @assetData()?._id

    @assetClassName = new ComputedField =>
      @options.documentClass?.className or @assetData()?.constructor.className
          
    @assetOptions = new ComputedField =>
      _.defaultsDeep {}, @options.assetOptions?(),
        upload:
          enabled: true
        storage:
          enabled: true
          
    @uploadingReferences = new ReactiveField []
    
    @references = new ComputedField =>
      return [] unless assetData = @assetData()

      # Reuse image ID on asset to minimize reactivity.
      assetReferences = _.cloneDeep(assetData.references) or []
      assetReference._id = assetReference.image._id for assetReference in assetReferences

      uploadingReferences = @uploadingReferences()

      # Merge existing and uploading references and sort by order.
      _.sortBy [assetReferences..., uploadingReferences...], (reference) => _.propertyValue(reference, 'order') or 0

    @highestOrder = new ComputedField =>
      return unless highestReference = _.last @references()
      _.propertyValue(highestReference, 'order') or 0

  removeUploadingReference: (referenceId, imageId) ->
    # Wait until references have updated and we have the new one with created image ID.
    @autorun (computation) =>
      # Make sure the component has finished loading the image, to prevent flickering.
      loadedComponents = @childComponentsWith (component) =>
        component.data().image?._id is imageId and component.imageSize()

      return unless loadedComponents.length
      computation.stop()

      uploadingReferences = @uploadingReferences()
      _.remove uploadingReferences, (uploadingReference) => uploadingReference._id is referenceId

      @uploadingReferences uploadingReferences
      
  startDrag: (options) ->
    @_dragStartMousePosition = options.mouseCoordinate
    @_dragStartReferencePosition = options.referencePosition

    options.reference.draggingPosition @_dragStartReferencePosition

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on "mouseup.landsofillusions-assets-components-references", (event) =>
      $(document).off '.landsofillusions-assets-components-references'

      # Make sure we still have the reference in case of recomputation during drag.
      return unless draggingReference = @draggingReference()
      draggingReference.endDrag()

      @draggingReference null

    $(document).on "mousemove.landsofillusions-assets-components-references", (event) =>
      scale = @display.scale() * @draggingScale()

      dragDelta =
        x: (event.pageX - @_dragStartMousePosition.x) / scale
        y: (event.pageY - @_dragStartMousePosition.y) / scale

      @draggingReference().draggingPosition
        x: @_dragStartReferencePosition.x + dragDelta.x
        y: @_dragStartReferencePosition.y + dragDelta.y

    # Set goal component last since it triggers reactivity.
    @draggingReference options.reference
    
  startResizing: (options) ->
    @_resizingReferenceCenter = options.referenceCenter
    @_resizingStartReferenceScale = options.referenceScale

    @_resizingVector = new THREE.Vector2 options.mouseCoordinate.x - @_resizingReferenceCenter.x, options.mouseCoordinate.y - @_resizingReferenceCenter.y
    @_resizingStartDistance = @_resizingVector.length()

    options.reference.resizingScale @_resizingStartReferenceScale

    # Wire end of resizing on mouse up anywhere in the window.
    $(document).on "mouseup.landsofillusions-assets-components-references", (event) =>
      $(document).off '.landsofillusions-assets-components-references'

      # Make sure we still have the reference in case of recomputation during resizing.
      return unless resizingReference = @resizingReference()
      resizingReference.endResizing()

      @resizingReference null

    $(document).on "mousemove.landsofillusions-assets-components-references", (event) =>
      @_resizingVector.x = event.clientX - @_resizingReferenceCenter.x
      @_resizingVector.y = event.clientY - @_resizingReferenceCenter.y
      resizingDistance = @_resizingVector.length()

      @resizingReference().resizingScale @_resizingStartReferenceScale * resizingDistance / @_resizingStartDistance

    # Set goal component last since it triggers reactivity.
    @resizingReference options.reference
    
  storedReferences: -> _.filter @references(), (reference) => not _.propertyValue reference, 'displayed'
  displayedReferences: -> _.filter @references(), (reference) => _.propertyValue reference, 'displayed'
  
  dragging: ->
    @draggingReference()?

  events: ->
    super(arguments...).concat
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
        order: new ReactiveField @highestOrder() + 0.1

      @uploadingReferences uploadingReferences

    $fileInput.click()

  onClickStorageButton: (event) ->
    # TODO
