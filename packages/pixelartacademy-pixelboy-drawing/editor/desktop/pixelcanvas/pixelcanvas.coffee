AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Desktop.PixelCanvas extends LOI.Assets.SpriteEditor.PixelCanvas
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Desktop.PixelCanvas'
  @register @id()
  
  template: -> @constructor.id()

  onCreated: ->
    super arguments...
  
    @drawing = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing
    @desktop = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Desktop
  
    # Allow triggering asset style change.
    @assetStyleChangeDependency = new Tracker.Dependency
  
    # Do updates when asset changes.
    @autorun (computation) =>
      @drawing.portfolio().displayedAsset()
    
      # Trigger asset style change after delay. We need this delay to allow for asset data in the
      # clipboard to update, which will change the position of the asset when attached to the clipboard.
      Meteor.setTimeout => @assetStyleChangeDependency.changed()

    @clipboardComponent = new ComputedField =>
      return unless clipboardComponent = @desktop.displayedAsset()?.clipboardComponent
      return unless clipboardComponent.isCreated()
      clipboardComponent
  
    # Update camera scale.
    @autorun (computation) =>
      return unless camera = @camera()
      return unless displayedAsset = @desktop.displayedAsset()
      return unless displayedAsset.clipboardComponent.isCreated()
      return unless clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
    
      # Dictate camera scale when asset is on clipboard and when setting for the first time.
      clipboardAssetScale = clipboardAssetSize.scale
    
      unless @desktop.active() and displayedAsset is @_previousDisplayedAsset and clipboardAssetScale is @_previousClipboardSpriteScale
        Tracker.nonreactive => camera.setScale clipboardAssetScale
    
      @_previousDisplayedAsset = displayedAsset
      @_previousClipboardSpriteScale = clipboardAssetScale

  hiddenClass: ->
    # Don't show the asset when clipboard is on the second page.
    'hidden' if @clipboardComponent()?.secondPageActive?()
    
  canvasAreaStyle: ->
    # Allow to be updated externally.
    @assetStyleChangeDependency.depend()

    # If nothing else, we should move the asset off screen.
    offScreenStyle = top: '-200rem'

    # Wait for clipboard to be rendered.
    return offScreenStyle unless @drawing.clipboard().isRendered()

    # If we don't have size data, don't return anything so transition will start form first value.
    return offScreenStyle unless displayedAsset = @desktop.displayedAsset()
    return offScreenStyle unless displayedAsset.clipboardComponent.isCreated()
    return offScreenStyle unless clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
    return offScreenStyle unless assetData = displayedAsset.document()
    
    editorActive = @desktop.active()
  
    if editorActive
      # When the editor is open, the size depends on the internal pixel canvas camera scale.
      return offScreenStyle unless scale = @camera().scale()
      
    else
      # When we're on the clipboard, the size depends on the size provided by the asset's clipboard component.
      scale = clipboardAssetSize.scale

    width = assetData.bounds.width * scale
    height = assetData.bounds.height * scale

    displayScale = LOI.adventure.interface.display.scale()

    if @desktop.drawingActive()
      # Add one pixel to the size for outer grid line.
      pixelInRem = 1 / displayScale

      width += pixelInRem
      height += pixelInRem

    # Resize the border proportionally to its clipboard size
    borderWidth = clipboardAssetSize.borderWidth / clipboardAssetSize.scale * scale

    if editorActive
      # We need to be in the middle of the table, but allowing for custom offset with dragging.
      offset = @desktop.canvasPositionOffset()

      # Update offset when scale changes, so that the same pixel will appear in the center.
      if @_previousScale and @_previousScale isnt scale
        offset =
          x: offset.x / @_previousScale * scale
          y: offset.y / @_previousScale * scale

        Tracker.nonreactive => @desktop.canvasPositionOffset offset

      @_previousScale = scale

      left = "calc(50% - #{width / 2 + borderWidth - offset.x}rem)"
      top = "calc(50% - #{height / 2 + borderWidth - offset.y}rem)"

    else
      $assetPlaceholder = $('.pixelartacademy-pixelboy-apps-drawing-clipboard .asset-placeholder')
      return {} unless $assetPlaceholder.length
      assetOffset = $assetPlaceholder.offset()

      $clipboard = $('.pixelartacademy-pixelboy-apps-drawing-clipboard')
      positionOrigin = $clipboard.offset()

      # Make these measurements relative to clipboard center.
      positionOrigin.left += $clipboard.width() / 2
      left = assetOffset.left - positionOrigin.left
      left = "calc(50% + #{left}px)"

      # Top is relative to center only when we have an active asset.
      activeAsset = @desktop.activeAsset()

      positionOrigin.top += $clipboard.height() / 2 if activeAsset
      top = assetOffset.top - positionOrigin.top

      if activeAsset
        top = "calc(50% + #{top}px)"

      else
        # Clipboard is hidden up, so move the asset up and relative to top.
        top -= 265 * displayScale

    style =
      width: "#{width}rem"
      height: "#{height}rem"
      left: left
      top: top
      borderWidth: "#{borderWidth}rem"

    if backgroundColor = displayedAsset.backgroundColor?()
      style.backgroundColor = "##{backgroundColor.getHexString()}"
      style.borderColor = style.backgroundColor
    
    style
