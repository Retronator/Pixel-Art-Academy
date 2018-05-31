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

    @size = new ReactiveField null

    # Dragging position is the local override while the reference is actively dragged.
    @draggingPosition = new ReactiveField null

    # Handle preview and uploading.
    @autorun (computation) =>
      reference = @data()

      if reference.file
        @_loadFilePreview reference
        @_uploadFile reference

        # Remove the file attribute to prevent re-uploading if data context changes.
        reference.file = null

  _loadFilePreview: (reference) ->
    reader = new FileReader()
    reader.onload = (event) => reference.preview event.target.result

    reader.readAsDataURL reference.file

  _uploadFile: (reference) ->
    LOI.Assets.Components.References.referenceUploadContext.upload reference.file, (url) =>
      # Add reference to asset.
      LOI.Assets.VisualAsset.addReferenceByUrl @references.options.assetId(), @references.options.documentClass.className, LOI.characterId(), url, reference.position(), reference.scale(), reference.displayed(), (error, imageId) =>
        if error
          console.error error
          return

        # Remove uploading reference.
        @references.removeUploadingReference reference._id, imageId

  endDrag: ->
    @setPosition @draggingPosition()
    @setDisplayed @references.draggingDisplayed()

    @draggingPosition null

  imageSource: ->
    reference = @data()
    reference.image?.url or reference.preview()

  referenceStyle: ->
    return display: 'none' unless size = @size()

    scale = @currentScale()

    if position = @draggingPosition()
      # Add parent offset since we expect positioned fixed.
      displayScale = @display.scale()

      position =
        x: @parentOffset.left / displayScale + position.x
        y: @parentOffset.top / displayScale + position.y
        
    else
      position = @currentPosition()

    left: "#{position.x}rem"
    top: "#{position.y}rem"
    width: "#{size.width * scale}rem"
    height: "#{size.height * scale}rem"

  currentPosition: ->
    return unless reference = @data()
    _.propertyValue(reference, 'position') or x: 0, y: 0

  currentScale: ->
    return unless reference = @data()
    _.propertyValue(reference, 'scale') or 1

  currentDisplayed: ->
    return unless reference = @data()
    _.propertyValue(reference, 'displayed') or false

  setPosition: (position) ->
    @_setReferenceProperty 'position', position

  setScale: (scale) ->
    @_setReferenceProperty 'scale', scale

  setDisplayed: (displayed) ->
    @_setReferenceProperty 'displayed', displayed
    
  _setReferenceProperty: (name, value) ->
    return unless reference = @data()
    upperName = _.upperFirst name
    
    return if EJSON.equals @["current#{upperName}"](), value

    if reference.image
      LOI.Assets.VisualAsset["updateReference#{upperName}"] @references.options.assetId(), @references.options.documentClass.className, reference.image._id, value

    else
      reference[name] value
      
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
    $parent = $reference.offsetParent()
    @parentOffset = $parent.offset()

    @references.startDrag
      reference: @
      referencePosition: @currentPosition()
      mouseCoordinate:
        x: event.pageX
        y: event.pageY
