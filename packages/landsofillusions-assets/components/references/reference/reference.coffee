AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.References.Reference extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.References.Reference'

  template: -> @constructor.id()
  @register @id()

  onCreated: ->
    super

    @references = @ancestorComponentOfType LOI.Assets.Components.References
    @display = @callAncestorWith 'display'

    @preview = new ReactiveField null
    @size = new ReactiveField null

    # Dragging position is the local override while the reference is actively dragged.
    @draggingPosition = new ReactiveField null

    # Position and scale fields are temporary reactive fields before image is uploaded.
    @position = new ReactiveField null
    @scale = new ReactiveField null

    # Handle preview and uploading.
    @autorun (computation) =>
      reference = @data()

      if reference.file
        @_loadFilePreview reference.file
        @_uploadFile reference.file
        
  _loadFilePreview: (file) ->
    reader = new FileReader()
    reader.onload = (event) => @preview event.target.result

    reader.readAsDataURL file

  _uploadFile: (file) ->
    uploadingReference = @data()

    LOI.Assets.Components.References.referenceUploadContext.upload file, (url) =>
      # Add reference to asset.
      LOI.Assets.VisualAsset.addReferenceByUrl @references.options.assetId(), @references.options.documentClass.className, LOI.characterId(), url

      # Remove uploading reference.
      @references.removeUploadingReference uploadingReference._id

  endDrag: (dragDelta) ->
    reference = @data()
    position = @position() or reference.position or x: 0, y: 0

    newPosition =
      x: position.x + dragDelta.x
      y: position.y + dragDelta.y

    # Update position.
    if reference.image
      unless EJSON.equals reference.position, newPosition
        LOI.Assets.VisualAsset.updateReferencePosition @references.options.assetId(), @references.options.documentClass.className, reference.image._id, newPosition

    else
      # This is an image that is still uploading so set the position directly to data as it will be uploaded later.
      @position newPosition

    @draggingPosition null

  imageSource: ->
    reference = @data()
    reference.image?.url or @preview()

  referenceStyle: ->
    reference = @data()

    return display: 'none' unless size = @size()

    scale = @scale() or reference.scale or 1
    position = @currentPosition()

    left: "#{position.x}rem"
    top: "#{position.y}rem"
    width: "#{size.width * scale}rem"
    height: "#{size.height * scale}rem"

  currentPosition: ->
    reference = @data()
    @draggingPosition() or @position() or reference.position or x: 0, y: 0

  draggingClass: ->
    'dragging' if @references.draggingReference() is @

  events: ->
    super.concat
      'load .image': @onLoadImage
      'mousedown': @onMouseDown

  onLoadImage: (event) ->
    @size
      width: event.target.width
      height: event.target.height

  onMouseDown: (event) ->
    return unless event.which is 1

    reference = @data()

    # Prevent browser select/dragging behavior
    event.preventDefault()

    @references.startDrag
      reference: @
      referencePosition: @currentPosition()
      mouseCoordinate:
        x: event.pageX
        y: event.pageY
