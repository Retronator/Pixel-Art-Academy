AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Project.Asset.Bitmap.ClipboardComponent.PreviewInfoMixin extends BlazeComponent
  onCreated: ->
    @drawing = @component().ancestorComponentOfType PAA.PixelPad.Apps.Drawing
    
    @assetInfoChangedDependency = new Tracker.Dependency

    @isAssetActive = new ComputedField =>
      return unless editor = @drawing.editor()
      return unless editor.isCreated()
      editor.activeAsset()?

    @previewPosition = new ReactiveField null, EJSON.equals

    @previewInfo = new ComputedField =>
      return unless assetSize = @component().assetSize()
      return unless previewPosition = @previewPosition()
      
      left = "calc(50% + #{previewPosition.left}rem)"
      
      if @isAssetActive()
        top = "calc(50% + #{previewPosition.top}rem)"
      
      else
        # When the asset is not active, the clipboard center is -145rem above the top of the screen.
        top = "#{previewPosition.top - 145}rem"
      
      scale: assetSize.scale
      borderWidth: assetSize.borderWidth
      position: {left, top}
    ,
      EJSON.equals
    
  onRendered: ->
    super arguments...
    
    $clipboard = $('.pixelartacademy-pixelpad-apps-drawing-clipboard')
    
    # Recalculate the position of the placeholder.
    @autorun (computation) =>
      # Don't measure when the second page is displayed.
      return if @component().secondPageActive()

      # Depend on the content above the placeholder.
      @assetInfoChangedDependency.depend()
      
      # Give a chance for the first page to be rendered.
      Tracker.afterFlush =>
        # Make sure we're still rendered.
        return unless @isRendered()
        
        # React to asset info changes.
        $assetInfo = @$('.asset-info')
  
        @_resizeObserver?.disconnect()
        @_resizeObserver = new ResizeObserver =>
          @assetInfoChangedDependency.changed()
      
        @_resizeObserver.observe $assetInfo[0]
        
        $assetPlaceholder = @$('.asset-placeholder')
        
        # Measure the placeholder relative to the center of the clipboard.
        assetOffset = $assetPlaceholder.offset()
        
        offsetOrigin = $clipboard.offset()
        offsetOrigin.left += $clipboard.width() / 2
        offsetOrigin.top += $clipboard.height() / 2
        
        scale = LOI.adventure.interface.display.scale()
        
        @previewPosition
          left: (assetOffset.left - offsetOrigin.left) / scale
          top: (assetOffset.top - offsetOrigin.top) / scale
    
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver?.disconnect()
