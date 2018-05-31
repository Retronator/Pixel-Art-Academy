AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School.References extends LOI.Assets.Components.References
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.References'
  @register @id()

  onCreated: ->
    super

    @opened = new ReactiveField false
    @hideActive = new ReactiveField false

    # The dragging reference should end up displayed if our tray is closed and hide is not active.
    @autorun (computation) =>
      @draggingDisplayed not @opened() and not @hideActive()

    # Close the tray when clicking outside of it.
    $(document).on 'click.pixelartacademy-pixelboy-apps-drawing-editor-theme-school-references', (event) =>
      return if $(event.target).closest('.pixelartacademy-pixelboy-apps-drawing-editor-theme-school-references').length

      @opened false

  onDestroyed: ->
    $(document).off '.pixelartacademy-pixelboy-apps-drawing-editor-theme-school-references'

  styleClasses: ->
    classes = [
      'opened' if @opened()
    ]

    _.without(classes, undefined).join ' '

  hideActiveClass: ->
    'hide-active' if @hideActive()
    
  events: ->
    super.concat
      'click .stored-references': @onClickStoredReferences

  onClickStoredReferences: (event) ->
    $target = $(event.target)
    opened = @opened()

    # Don't react to clicks on references to prevent opening on drag end.
    return if $target.closest('.reference').length

    if opened
      # Only react to clicks directly on the stored references.
      return if $target.closest('.actions').length

    @opened not opened

  class @Reference extends LOI.Assets.Components.References.Reference
    @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.References.Reference'

    constructor: ->
      super

      @trayWidth = 165
      @trayHeight = 190
      @trayHideActiveHeight = 10
      @trayBorder = 8

    onCreated: ->
      super

      # Automatically scale and position the image when not displayed.
      @autorun (computation) =>
        reference = @data()
        return unless size = @size()
        return if @currentDisplayed()

        # Scale should be such that 100^2 pixels are covered, but any side is not larger than 150 pixels.
        scale = Math.min 100 / Math.sqrt(size.width * size.height), Math.min 150 / size.width, 150 / size.height
        @setScale scale

        # Make sure reference is within the tray.
        halfWidth = size.width * scale / 2
        halfHeight = size.height * scale / 2

        position = @currentPosition()

        maxX = @trayWidth / 2 - halfWidth - @trayBorder
        maxY = @trayHeight / 2 - halfHeight - @trayBorder

        position =
          x: _.clamp position.x, -maxX, maxX
          y: _.clamp position.y, -maxY, maxY

        @setPosition position

      @autorun (computation) =>
        return unless draggingPosition = @draggingPosition()
        return unless size = @size()
        scale = @currentScale()
        displayScale = @display.scale()

        halfWidth = size.width * scale / 2
        halfHeight = size.height * scale / 2

        # Close references when moving outside the tray.
        if @references.opened() and Math.abs(draggingPosition.x) + halfWidth > @trayWidth / 2 or Math.abs(draggingPosition.y) + halfHeight > @trayHeight / 2
          @references.opened false

        # Activate hide mode when nearing tray.
        @references.hideActive not @references.opened() and Math.abs(draggingPosition.x) < @trayWidth / 2 and draggingPosition.y + @parentOffset.top / displayScale - halfHeight < @trayHideActiveHeight
    
    onMouseDown: (event) ->
      super
      
      # Parent offset will be relative to PixelBoy viewport so we need to remove it.
      $pixelBoy = $('.pixelartacademy-pixelboy-os').eq(0)
      pixelBoyOffset = $pixelBoy.offset()

      @parentOffset.left -= pixelBoyOffset.left
      @parentOffset.top -= pixelBoyOffset.top

    referenceStyle: ->
      style = super

      # Push assets apart when we're not editing an asset.
      if @currentDisplayed() and not @references.options.editorActive()
        position = new THREE.Vector2 parseFloat(style.left), (parseFloat style.top)

        distance = new THREE.Vector2(240, 180).length()

        if size = @size()
          scale = @currentScale()
          halfWidth = size.width * scale / 2
          halfHeight = size.height * scale / 2

          distance += new THREE.Vector2(halfWidth, halfHeight).length()

        position.normalize().multiplyScalar(distance)

        style.left = "#{position.x}rem"
        style.top = "#{position.y}rem"

      style
