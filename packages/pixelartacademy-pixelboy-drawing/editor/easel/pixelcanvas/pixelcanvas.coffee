AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Easel.PixelCanvas extends LOI.Assets.SpriteEditor.PixelCanvas
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Easel.PixelCanvas'
  @register @id()
  
  template: -> @constructor.id()

  onCreated: ->
    super arguments...
  
    @drawing = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing
    @easel = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing.Editor.Easel
  
    # Allow triggering asset style change.
    @assetStyleChangeDependency = new Tracker.Dependency
  
    # Do updates when asset changes.
    @autorun (computation) =>
      return unless portfolioAsset = @drawing.portfolio().displayedAsset()
      
      # Wait until the asset is ready.
      portfolioAsset.asset.ready()
    
      # Trigger asset style change after delay. We need this delay to allow for asset data in the
      # clipboard to update, which will change the position of the asset when attached to the clipboard.
      Meteor.setTimeout => @assetStyleChangeDependency.changed()

    @clipboardComponent = new ComputedField =>
      return unless clipboardComponent = @easel.displayedAsset()?.clipboardComponent
      return unless clipboardComponent.isCreated()
      clipboardComponent
  
    # Update camera scale.
    @autorun (computation) =>
      return unless camera = @camera()
      return unless displayedAsset = @easel.displayedAsset()
      return unless displayedAsset.clipboardComponent.isCreated()
      return unless clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
    
      # Dictate camera scale when asset is on clipboard and normal display mode.
      clipboardAssetScale = clipboardAssetSize.scale
      normalDisplayMode = @easel.displayMode() is PAA.PixelBoy.Apps.Drawing.Editor.Easel.DisplayModes.Normal
    
      if not @easel.active() or normalDisplayMode or displayedAsset isnt @_previousDisplayedAsset or clipboardAssetScale isnt @_previousClipboardSpriteScale
        Tracker.nonreactive => camera.setScale clipboardAssetScale
    
      @_previousDisplayedAsset = displayedAsset
      @_previousClipboardSpriteScale = clipboardAssetScale
  
    # Switch between full and framed display modes.
    @autorun (computation) =>
      easelActive = @easel.active()
      
      Tracker.nonreactive =>
        newDisplayMode = if easelActive then LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Framed else LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        @displayMode newDisplayMode
        
  hiddenClass: ->
    # Don't show the asset when clipboard is on the second page.
    'hidden' if @clipboardComponent()?.secondPageActive?()
    
  drawingAreaStyle: ->
    # Allow to be updated externally.
    @assetStyleChangeDependency.depend()

    # If nothing else, we should move the asset off screen.
    offScreenStyle = top: '-200rem'

    # Wait for clipboard to be rendered.
    return offScreenStyle unless @drawing.clipboard().isRendered()

    # If we don't have size data, don't return anything so transition will start form first value.
    return offScreenStyle unless displayedAsset = @easel.displayedAsset()
    return offScreenStyle unless displayedAsset.clipboardComponent.isCreated()
    return offScreenStyle unless clipboardAssetSize = displayedAsset.clipboardComponent.assetSize()
    return offScreenStyle unless assetData = displayedAsset.document()
    
    editorActive = @easel.active()
    
    activeZoomedIn = editorActive and @easel.displayMode() isnt PAA.PixelBoy.Apps.Drawing.Editor.Easel.DisplayModes.Normal
  
    if activeZoomedIn
      # When the editor is open and zoomed in, the size depends on the internal pixel canvas camera scale.
      return offScreenStyle unless scale = @camera().scale()
      
    else
      # When we're on the clipboard or in normal display mode, the size depends on the size provided by the asset's clipboard component.
      scale = clipboardAssetSize.scale

    width = assetData.bounds.width * scale
    height = assetData.bounds.height * scale

    displayScale = LOI.adventure.interface.display.scale()

    # Resize the border proportionally to its clipboard size
    borderWidth = clipboardAssetSize.borderWidth / clipboardAssetSize.scale * scale

    if editorActive
      # Let the parent implementation handle positioning.
      style = super arguments...
      
      # Remove the border.
      style.left = "#{style.left.substring(0, style.left.length - 1)} - #{borderWidth}rem)"
      style.top = "#{style.top.substring(0, style.top.length - 1)} - #{borderWidth}rem)"

    else
      $assetPlaceholder = $('.pixelartacademy-pixelboy-apps-drawing-clipboard .asset-placeholder')
      unless $assetPlaceholder.length
        # Force re-measure after the asset placeholder is visible again.
        Meteor.setTimeout => @assetStyleChangeDependency.changed()
        return {}

      assetOffset = $assetPlaceholder.offset()

      $clipboard = $('.pixelartacademy-pixelboy-apps-drawing-clipboard')
      positionOrigin = $clipboard.offset()

      # Make these measurements relative to clipboard center.
      positionOrigin.left += $clipboard.width() / 2
      left = assetOffset.left - positionOrigin.left
      left = "calc(50% + #{left}px)"

      # Top is relative to center only when we have an active asset.
      activeAsset = @easel.activeAsset()

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
        
    style.borderWidth = "#{borderWidth}rem"

    if backgroundColor = displayedAsset.backgroundColor?()
      style.backgroundColor = "##{backgroundColor.getHexString()}"
      style.borderColor = style.backgroundColor
    
    style
