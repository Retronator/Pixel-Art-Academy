AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference extends LOI.Assets.Components.References.Reference
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.References.DisplayComponent.Reference'
  @register @id()

  constructor: ->
    super arguments...

    @trayWidth = 165
    @trayHeight = 190
    @trayHideActiveHeight = 10
    # We need 13 pixels clearance so the reference doesn't appear when hovering over the tray.
    @trayBorder = 13

    # This represent the border around the reference as visible to the player.
    @referenceBorder = 4

    # We increase the resizing width beyond the visual border to make it easier to resize.
    @resizingBorder = 6

  onCreated: ->
    super arguments...

    # Subscribe to artworks for this reference.
    @autorun (computation) =>
      return unless reference = @data()
      return unless url = reference.image?.url

      PADB.Artwork.forUrl.subscribe @, url

    # Automatically scale and position the image when not displayed.
    @hiddenScale = new ReactiveField null
    @hiddenPosition = new ReactiveField null, EJSON.equals
    
    @autorun (computation) =>
      return unless reference = @data()
      return unless @references.assetId()
      return unless imageSize = @imageSize()
      
      if @currentDisplayed()
        Tracker.nonreactive =>
          @hiddenScale null
          @hiddenPosition null
        
        return

      # Scale should be such that 100^2 pixels are covered, but any side is not larger than 150 pixels.
      scale = Math.min 100 / Math.sqrt(imageSize.width * imageSize.height), Math.min 150 / imageSize.width, 150 / imageSize.height
      Tracker.nonreactive => @hiddenScale scale
  
      return unless displaySize = @displaySize scale
  
      # Make sure reference is within the tray.
      halfWidth = displaySize.width / 2 + @referenceBorder
      halfHeight = displaySize.height / 2 + @referenceBorder

      position = _.propertyValue(reference, 'position') or x: 0, y: 0

      maxX = @trayWidth / 2 - halfWidth - @trayBorder
      maxY = @trayHeight / 2 - halfHeight - @trayBorder

      position =
        x: _.clamp position.x, -maxX, maxX
        y: _.clamp position.y, -maxY, maxY
  
      Tracker.nonreactive => @hiddenPosition position

    @autorun (computation) =>
      return unless draggingPosition = @draggingPosition()
      
      referenceScale = if @currentDisplayed() then @currentScale() else @hiddenScale()
      return unless displaySize = @displaySize referenceScale

      halfWidth = displaySize.width / 2
      halfHeight = displaySize.height / 2

      # Close references when moving outside the tray.
      if @references.opened() and Math.abs(draggingPosition.x) + halfWidth > @trayWidth / 2 or Math.abs(draggingPosition.y) + halfHeight > @trayHeight / 2
        @references.opened false

      # Activate hide mode when nearing tray.
      displayScale = @display.scale()
      @references.hideActive not @references.opened() and Math.abs(draggingPosition.x) < @trayWidth / 2 and draggingPosition.y + @parentOffset.top / displayScale - halfHeight < @trayHideActiveHeight

    @caption = new ComputedField =>
      reference = @data()
      return if reference.displayOptions?.imageOnly

      # Find an artwork that matches this reference.
      return unless image = reference.image
      return unless artwork = PADB.Artwork.forUrl.query(image.url).fetch()[0]

      # Format as Title, Authors, Year.
      elements = []

      elements.push artwork.title if artwork.title

      authors = (author.displayName for author in artwork.authors)
      elements.push AB.Rules.English.createNounSeries authors if authors.length

      if _.isDate artwork.completionDate
        year = artwork.completionDate.getFullYear()

      else
        year = artwork.completionDate?.year

      elements.push year if year

      elements.join ', '
      
  currentPosition: ->
    return hiddenPosition if hiddenPosition = @hiddenPosition()
  
    position = super arguments...
    
    # Don't allow the reference to go off screen. We ensure enough of it is left
    # on screen (20%) that it doesn't get covered by items like the calculator.
    return hiddenPosition unless displaySize = @displaySize()
    editorSize = @references.options.editorSize()
    
    maxX = editorSize.width / 2 + displaySize.width * 0.3
    maxY = editorSize.height / 2 + displaySize.height * 0.3
    
    x: _.clamp position.x, -maxX, maxX
    y: _.clamp position.y, -maxY, maxY

  imageOnlyClass: ->
    reference = @data()
    'image-only' if reference.displayOptions?.imageOnly

  displaySize: (scale) ->
    return unless imageSize = @imageSize()

    scale ?= @currentScale()
    captionHeight = if @isRendered() and @caption() then 10 else 0

    width: imageSize.width * scale
    height: imageSize.height * scale + captionHeight

  endDrag: ->
    @startUpdate()
    
    # When displaying a reference, also set its scale from its hidden default.
    @setScale @hiddenScale() if @references.draggingDisplayed() and not @currentDisplayed()
  
    super arguments...

    @references.hideActive false

  onPointerDown: (event) ->
    super arguments...
    
    return unless event.which is 1

    unless @resizingDirection()
      # Parent offset will be relative to PixelPad viewport so we need to remove it.
      $pixelPad = $('.pixelartacademy-pixelpad-os').eq(0)
      pixelPadOffset = $pixelPad.offset()

      @parentOffset.left -= pixelPadOffset.left
      @parentOffset.top -= pixelPadOffset.top

  onPointerMove: (event) ->
    # Don't allow resizing when not displayed.
    return unless @currentDisplayed()

    super arguments...

  referenceStyle: ->
    currentDisplayed = @currentDisplayed()
    
    if currentDisplayed
      style = super arguments...
      
    else
      style = @hiddenReferenceStyle()

    # Push assets apart when we're not editing an asset.
    if currentDisplayed and not @references.options.editorActive()
      position = new THREE.Vector2 parseFloat(style.left), (parseFloat style.top)

      distance = new THREE.Vector2(240, 180).length()

      if displaySize = @displaySize()
        halfWidth = displaySize.width / 2
        halfHeight = displaySize.height / 2

        distance += new THREE.Vector2(halfWidth, halfHeight).length()

      position.normalize().multiplyScalar(distance)

      style.left = "#{position.x}rem"
      style.top = "#{position.y}rem"

    style

  hiddenReferenceStyle: ->
    scale = @hiddenScale()
    
    # We calculate the display size using the potentially hidden scale.
    return display: 'none' unless displaySize = @displaySize scale
    
    if position = @draggingPosition()
      # Add parent offset since we expect positioned fixed.
      displayScale = @display.scale()
      
      position =
        x: @parentOffset.left / displayScale + position.x
        y: @parentOffset.top / displayScale + position.y
    
    else
      position = @hiddenPosition()
    
    left: "#{position.x}rem"
    top: "#{position.y}rem"
    width: "#{displaySize.width}rem"
    height: "#{displaySize.height}rem"
