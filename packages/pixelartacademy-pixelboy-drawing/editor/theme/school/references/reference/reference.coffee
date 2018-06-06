AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School.References.Reference extends LOI.Assets.Components.References.Reference
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.References.Reference'
  @register @id()

  constructor: ->
    super

    @trayWidth = 165
    @trayHeight = 190
    @trayHideActiveHeight = 10
    @trayBorder = 8

    @resizingBorder = 4

  onCreated: ->
    super

    # Subscribe to artworks for this reference.
    @autorun (computation) =>
      return unless reference = @data()
      return unless url = reference.image?.url

      PADB.Artwork.forUrl.subscribe @, url

    # Automatically scale and position the image when not displayed.
    @autorun (computation) =>
      return unless imageSize = @imageSize()
      return unless displaySize = @displaySize()
      return if @currentDisplayed()

      # Scale should be such that 100^2 pixels are covered, but any side is not larger than 150 pixels.
      scale = Math.min 100 / Math.sqrt(imageSize.width * imageSize.height), Math.min 150 / imageSize.width, 150 / imageSize.height
      @setScale scale

      # Make sure reference is within the tray.
      halfWidth = displaySize.width / 2
      halfHeight = displaySize.height / 2

      position = @currentPosition()

      maxX = @trayWidth / 2 - halfWidth - @trayBorder
      maxY = @trayHeight / 2 - halfHeight - @trayBorder

      position =
        x: _.clamp position.x, -maxX, maxX
        y: _.clamp position.y, -maxY, maxY

      @setPosition position

    @autorun (computation) =>
      return unless draggingPosition = @draggingPosition()
      return unless displaySize = @displaySize()
      displayScale = @display.scale()

      halfWidth = displaySize.width / 2
      halfHeight = displaySize.height / 2

      # Close references when moving outside the tray.
      if @references.opened() and Math.abs(draggingPosition.x) + halfWidth > @trayWidth / 2 or Math.abs(draggingPosition.y) + halfHeight > @trayHeight / 2
        @references.opened false

      # Activate hide mode when nearing tray.
      @references.hideActive not @references.opened() and Math.abs(draggingPosition.x) < @trayWidth / 2 and draggingPosition.y + @parentOffset.top / displayScale - halfHeight < @trayHideActiveHeight

    @caption = new ComputedField =>
      reference = @data()

      # Find an artwork that matches this reference.
      return unless artwork = PADB.Artwork.forUrl.query(reference.sourceUrl).fetch()[0]

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

  displaySize: (scale) ->
    return unless imageSize = @imageSize()

    scale ?= @currentScale()
    captionHeight = if @isRendered() and @caption() then 10 else 0

    width: imageSize.width * scale
    height: imageSize.height * scale + captionHeight

  onMouseDown: (event) ->
    super
    
    return unless event.which is 1

    unless @resizingDirection()
      # Parent offset will be relative to PixelBoy viewport so we need to remove it.
      $pixelBoy = $('.pixelartacademy-pixelboy-os').eq(0)
      pixelBoyOffset = $pixelBoy.offset()

      @parentOffset.left -= pixelBoyOffset.left
      @parentOffset.top -= pixelBoyOffset.top

  onMouseMove: (event) ->
    # Don't allow resizing when not displayed.
    return unless @currentDisplayed()

    super

  referenceStyle: ->
    style = super

    # Push assets apart when we're not editing an asset.
    if @currentDisplayed() and not @references.options.editorActive()
      position = new THREE.Vector2 parseFloat(style.left), (parseFloat style.top)

      distance = new THREE.Vector2(240, 180).length()

      if displaySize = @size()
        halfWidth = displaySize.width / 2
        halfHeight = displaySize.height / 2

        distance += new THREE.Vector2(halfWidth, halfHeight).length()

      position.normalize().multiplyScalar(distance)

      style.left = "#{position.x}rem"
      style.top = "#{position.y}rem"

    style
