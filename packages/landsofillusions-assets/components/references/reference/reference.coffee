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
    position = @draggingPosition()

    opened = @references.opened()
    displayed = not opened

    # Update position.
    if reference.image
      unless EJSON.equals reference.position, position
        LOI.Assets.VisualAsset.updateReferencePosition @references.options.assetId(), @references.options.documentClass.className, reference.image._id, position

      unless reference.displayed is displayed
        LOI.Assets.VisualAsset.updateReferenceDisplayed @references.options.assetId(), @references.options.documentClass.className, reference.image._id, displayed

    else
      # This is an image that is still uploading so set the position directly to data as it will be uploaded later.
      @position position
      @displayed displayed

    @draggingPosition null

  imageSource: ->
    reference = @data()
    reference.image?.url or @preview()

  referenceStyle: ->
    return display: 'none' unless size = @size()

    scale = @currentScale()
    position = @currentPosition()

    if @draggingPosition()
      # Add parent offset since we expect positioned fixed.
      displayScale = @display.scale()

      position =
        x: @parentOffset.left / displayScale + position.x
        y: @parentOffset.top / displayScale + position.y

    left: "#{position.x}rem"
    top: "#{position.y}rem"
    width: "#{size.width * scale}rem"
    height: "#{size.height * scale}rem"

  currentPosition: ->
    reference = @data()
    @draggingPosition() or @position() or reference.position or x: 0, y: 0

  currentScale: ->
    reference = @data()
    @scale() or reference.scale or 1

  currentDisplayed: ->
    reference = @data()
    @displayed() or reference.displayed or false

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

    # Prevent browser select/dragging behavior
    event.preventDefault()

    # Save parent offset at start of dragging.
    $reference = @$('div').eq(0)
    @parentOffset = $reference.parent().offset()

    @references.startDrag
      reference: @
      referencePosition: @currentPosition()
      mouseCoordinate:
        x: event.pageX
        y: event.pageY
