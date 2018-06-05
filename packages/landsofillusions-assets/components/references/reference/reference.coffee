AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.References.Reference extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.References.Reference'

  template: -> @constructor.id()
  @register @id()

  @ResizingDirections:
    North: 'n'
    South: 's'
    East: 'e'
    West: 'w'
    Northeast: 'ne'
    Northwest: 'nw'
    Southeast: 'se'
    Southwest: 'sw'

  constructor: ->
    super

    # Overwrite to define the border width withing which resizing should be active.
    @resizingBorder = 0

  onCreated: ->
    super

    @references = @ancestorComponentOfType LOI.Assets.Components.References
    @display = @callAncestorWith 'display'

    @size = new ReactiveField null

    # Dragging position hold the temporary position when the reference is actively dragged.
    @draggingPosition = new ReactiveField null

    @resizingDirection = new ReactiveField null
    @resizingScale = new ReactiveField null

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

  captionHeight: -> 0 # Override to provide the caption height in REM units if the reference has a caption.

  endDrag: ->
    @setPosition @draggingPosition()
    @setDisplayed @references.draggingDisplayed()
    @reorderToTop() unless @currentOrder() is @references.highestOrder()

    @draggingPosition null

  endResizing: ->
    @setScale @resizingScale()
    @resizingScale null

  imageSource: ->
    reference = @data()
    reference.image?.url or reference.preview()

  referenceStyle: ->
    return display: 'none' unless size = @size()

    scale = @currentScale()

    resizingScale = @resizingScale()
    scale = resizingScale if resizingScale?

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
    height: "#{size.height * scale + @captionHeight()}rem"

  resizingDirectionClass: ->
    resizingDirection = @resizingDirection()
    "resizing-#{resizingDirection}" if resizingDirection

  currentPosition: ->
    return unless reference = @data()
    _.propertyValue(reference, 'position') or x: 0, y: 0

  currentScale: ->
    return unless reference = @data()
    _.propertyValue(reference, 'scale') or 1

  currentDisplayed: ->
    return unless reference = @data()
    _.propertyValue(reference, 'displayed') or false

  currentOrder: ->
    return unless reference = @data()
    _.propertyValue(reference, 'order') or 0

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

  reorderToTop: ->
    return unless reference = @data()

    if reference.image
      LOI.Assets.VisualAsset.reorderReferenceToTop  @references.options.assetId(), @references.options.documentClass.className, reference.image._id

    else
      # We increase order only by .1 to allow other references to get higher via database calls.
      reference.order @references.highestOrder() + 0.1

  draggingClass: ->
    'dragging' if @references.draggingReference() is @

  events: ->
    super.concat
      'load .image': @onLoadImage
      'mousedown': @onMouseDown
      'mousemove': @onMouseMove
      'mouseleave': @onMouseLeave

  onLoadImage: (event) ->
    @size
      width: event.target.width
      height: event.target.height

  onMouseDown: (event) ->
    return unless event.which is 1

    # Prevent browser select/dragging behavior
    event.preventDefault()

    $reference = $(@firstNode())

    if @resizingDirection()
      # Resizing. Calculate reference center.
      offset = $reference.offset()

      @references.startResizing
        reference: @
        referenceScale: @currentScale()
        referenceCenter:
          x: offset.left + $reference.outerWidth() / 2
          y: offset.top + $reference.outerHeight() / 2
        mouseCoordinate:
          x: event.clientX
          y: event.clientY
    else
      # Dragging. Save parent offset at start of dragging.
      $parent = $reference.offsetParent()
      @parentOffset = $parent.offset()

      @references.startDrag
        reference: @
        referencePosition: @currentPosition()
        mouseCoordinate:
          x: event.clientX
          y: event.clientY

  onMouseMove: (event) ->
    return if @resizingScale()?

    size = @size()
    scale = @currentScale()
    displayScale = @display.scale()

    width = size.width * scale
    height = size.height * scale + @captionHeight()

    offset = $(event.target).offset()

    x = (event.clientX - offset.left) / displayScale
    y = (event.clientY - offset.top) / displayScale

    direction = ''

    direction += 'n' if y < @resizingBorder
    direction += 's' if y > height - @resizingBorder
    direction += 'w' if x < @resizingBorder
    direction += 'e' if x > width - @resizingBorder

    @resizingDirection direction

  onMouseLeave: (event) ->
    return if @resizingScale()?

    @resizingDirection null
