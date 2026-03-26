AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAG = PAA.Practice.PixelArtEvaluation

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelCanvas extends LOI.Assets.SpriteEditor.PixelCanvas
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.PixelCanvas'
  @register @id()

  onCreated: ->
    super arguments...
    
    @drawing = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
  
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
      return unless clipboardComponent = @desktop.displayedAsset()?.clipboardComponent
      return unless clipboardComponent.isCreated()
      clipboardComponent
  
    # Update camera scale.
    @autorun (computation) =>
      return unless camera = @camera()
      return unless displayedAsset = @desktop.displayedAsset()
      return unless previewInfo = displayedAsset.previewInfo()
    
      # Dictate camera scale when not active and when setting for the first time.
      unless @desktop.active() and @_initialScaleSet
        Tracker.nonreactive => camera.setScale previewInfo.scale
        @_initialScaleSet = true

    # Update border width.
    @autorun (computation) =>
      borderWidth = @_borderWidth()
      
      # Make sure we were able to compute the new border (we don't
      # want the pixel canvas to update with temporary values).
      return unless borderWidth?

      Tracker.nonreactive => @borderWidth borderWidth
      
    # Switch between full and framed display modes.
    @autorun (computation) =>
      desktopActive = @desktop.active()
      
      Tracker.nonreactive =>
        newDisplayMode = if desktopActive then LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Framed else LOI.Assets.SpriteEditor.PixelCanvas.DisplayModes.Full
        @displayMode newDisplayMode
      
    # Reset camera origin when entering the editor. We should wait until asset data exists in
    # case it's still being loaded (such as when entering directly into the editor via URL).
    @_assetDataExists = new ComputedField => @assetData()?
  
    @autorun (computation) =>
      return unless @desktop.active()
      return unless @_assetDataExists()
    
      Tracker.nonreactive =>
        assetData = @assetData()
        originDataField = @camera().originData()
        
        if assetData.bounds
          # The center of the image should be in the origin.
          originDataField.value
            x: (assetData.bounds.left + assetData.bounds.right + 1) / 2
            y: (assetData.bounds.top + assetData.bounds.bottom + 1) / 2
          
        else
          originDataField.value x: 0, y: 0
    
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
    return offScreenStyle unless displayedAsset = @desktop.displayedAsset()
    return offScreenStyle unless previewInfo = displayedAsset.previewInfo()
    return offScreenStyle unless assetData = displayedAsset.document()
    
    editorActive = @desktop.active()
  
    if editorActive
      # When the editor is open, the size depends on the internal pixel canvas camera scale.
      return offScreenStyle unless scale = @camera().scale()
      
    else
      # When we're outside the editor, the scale comes from the preview.
      scale = previewInfo.scale
    
    if editorActive
      # Let the parent implementation handle positioning.
      style = super arguments...

    else
      borderWidth = @_borderWidth() or 0
      width = (assetData.bounds.width + 2 * borderWidth) * scale
      height = (assetData.bounds.height + 2 * borderWidth) * scale
  
      style =
        width: "#{width}rem"
        height: "#{height}rem"
        left: previewInfo.position.left
        top: previewInfo.position.top
        
    if backgroundColor = displayedAsset.backgroundColor?()
      style.backgroundColor = "##{backgroundColor.getHexString()}"
      style.borderColor = style.backgroundColor
    
    style
    
  _borderWidth: ->
    return unless displayedAsset = @desktop.displayedAsset()
    return unless previewInfo = displayedAsset.previewInfo()
    
    # Convert from display to asset pixels.
    previewInfo.borderWidth / previewInfo.scale
  
  letterGrade: ->
    return unless displayedAsset = @desktop.displayedAsset()
    return unless pixelArtEvaluation = displayedAsset.document()?.properties?.pixelArtEvaluation
    return if pixelArtEvaluation.displayed is false
    return unless pixelArtEvaluation.score?
    PAG.getLetterGrade pixelArtEvaluation.score
