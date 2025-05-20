AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Shape extends LOI.Assets.SpriteEditor.Tools.Tool
  constructor: ->
    super arguments...

    @drawingActive = new ReactiveField false

    @startPixelCoordinates = new ReactiveField null
    @currentPixelCoordinates = new ReactiveField null

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    @pixels = new ReactiveField null
    
    # Request realtime updates when actively changing pixels.
    @realtimeUpdating = new ReactiveField false

  onActivated: ->
    @updateShape()
    
    @_previewActive = false

    @_cursorChangesAutorun = @autorun (computation) =>
      # React to cursor changes.
      if @cursorType() is LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AliasedBrush
        return unless @editor()?.cursor().cursorArea().aliasedShape
        
      else
        return unless @editor()?.pointer().pixelCoordinate()
        
      Tracker.nonreactive => @updateShape()

    @_updatePreviewAutorun = @autorun (computation) =>
      return unless editor = @editor()
  
      # Show preview when we have a valid cursor.
      preview = @editor()?.cursor().cursorArea().position

      if preview
        # Update preview pixels.
        editor.operationPreview().pixels @pixels()

      else if @_previewActive
        # Remove pixels, since we were the ones providing them.
        editor.operationPreview().pixels []

      @_previewActive = preview

  onDeactivated: ->
    @endDrawing()
    
    @realtimeUpdating false
    
    @_cursorChangesAutorun.stop()
    @_updatePreviewAutorun.stop()
    @editor().operationPreview().pixels [] if @_previewActive
  
  isEngaged: -> @startPixelCoordinates()?

  onKeyDown: (event) ->
    super arguments...

    if @startPixelCoordinates()
      # React to any modifier changes when drawing.
      @updateShape()

  onKeyUp: (event) ->
    super arguments...

    if @startPixelCoordinates()
      # React to any modifier changes when drawing.
      @updateShape()

  onPointerDown: (event) ->
    super arguments...
    
    # Only react to the main button.
    return if event.button
    
    @startDrawing()
  
  onPointerUp: (event) ->
    super arguments...
    
    @endDrawing()
    
  startDrawing: ->
    # Only react when the pointer has a valid position.
    @startPixelCoordinates @getNewPixelCoordinates()
    
    @drawingActive true
    @realtimeUpdating true

    # If pointer down and move happen in the same frame (such as when using a stylus), allow the cursor to fully update.
    Tracker.afterFlush => @updateShape()
    
  getNewPixelCoordinates: (event) ->
    if @cursorType() is LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AliasedBrush
      return unless cursorArea = @editor()?.cursor().cursorArea()
      return unless cursorArea.position
      
      _.clone cursorArea.position.centerCoordinates
    
    else
      return unless pixelCoordinates = @editor()?.pointer().pixelCoordinate()
      
      _.clone pixelCoordinates

  endDrawing: ->
    return unless @drawingActive()
    
    # Make sure we still have a valid position.
    if @cursorType() is LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AliasedBrush
      positionValid = @editor()?.cursor().cursorArea().position
      
    else
      positionValid = @editor()?.pointer().pixelCoordinate()
    
    # Draw shape.
    @applyTool() if positionValid
    
    # Clean up.
    @startPixelCoordinates null
    @drawingActive false
    @realtimeUpdating false

    @updatePixels()
  
  updateShape: ->
    currentPixelCoordinates = @currentPixelCoordinates()
    newPixelCoordinates = @getNewPixelCoordinates()

    # Update coordinates if they are new.
    unless EJSON.equals currentPixelCoordinates, newPixelCoordinates
      @currentPixelCoordinates newPixelCoordinates

    @updatePixels()

  updatePixels: ->
    # Override to create the pixels the shape covers.

  applyTool: ->
    return unless @drawingActive()
    
    assetData = @editor().assetData()
    layerIndex = @paintHelper.layerIndex()
    layer = assetData.layers?[layerIndex]
    
    relativePixels = LOI.Assets.SpriteEditor.Tools.AliasedStroke.createRelativePixels assetData, layer, @pixels()

    # See if we're only painting normals.
    pencil = @interface.getOperator LOI.Assets.SpriteEditor.Tools.Pencil
    paintNormals = pencil.data.get 'paintNormals'
    ignoreNormals = pencil.data.get 'ignoreNormals'

    action = new AM.Document.Versioning.Action @constructor.id()
    LOI.Assets.SpriteEditor.Tools.Pencil.applyPixels assetData, action, layerIndex, relativePixels, paintNormals, ignoreNormals
    assetData.executeAction action
