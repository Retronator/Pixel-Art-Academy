AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Instructions.Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
  # The default amount of time before we show instructions to the user to let them figure it out themselves
  @defaultDelayDuration = 10
  
  @assetClass: -> throw new AE.NotImplementedException "You must specify the asset class this instruction is for."
  
  @getEditor: ->
    return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    return unless currentApp = pixelPad.os.currentApp()
    return unless currentApp instanceof PAA.PixelPad.Apps.Drawing
    drawing = currentApp
    drawing.editor()
    
  @getActiveAsset: ->
    # We must be in the editor on the provided asset.
    return unless editor = @getEditor()
    return unless editor.drawingActive()
    
    return unless asset = editor.activeAsset()
    return unless asset instanceof @assetClass()
    
    asset

  @assetHasExtraPixels: (asset) ->
    # Compare goal layer with current bitmap layer.
    return unless bitmapLayer = asset.bitmap()?.layers[0]
    return unless goalPixelsMap = asset.goalPixelsMap()
    return unless asset.palette()

    backgroundColor = asset.getBackgroundColor()

    for x in [0...bitmapLayer.width]
      for y in [0...bitmapLayer.height]
        pixel = bitmapLayer.getPixel(x, y)
        goalPixel = goalPixelsMap[x]?[y]

        # If there is a pixel but no goal pixel, we have an extra pixel.
        if pixel? and not goalPixel?
          # Make sure the extra pixel doesn't match the background color.
          return true unless backgroundColor
    
          pixelIntegerDirectColor = if pixel.paletteColor then @_paletteToIntegerDirectColor pixel.paletteColor else @_directToIntegerDirectColor pixel.directColor
          return true unless EJSON.equals pixelIntegerDirectColor, backgroundColor.integerDirectColor

    false
    
  @assetHasMissingPixels: (asset) ->
    # Compare goal layer with current bitmap layer.
    return unless bitmapLayer = asset.bitmap()?.layers[0]
    return unless goalPixelsMap = asset.goalPixelsMap()
    return unless asset.palette()

    backgroundColor = asset.getBackgroundColor()

    for x in [0...bitmapLayer.width]
      for y in [0...bitmapLayer.height]
        pixel = bitmapLayer.getPixel(x, y)
        goalPixel = goalPixelsMap[x]?[y]

        # If there is a goal pixel but no image pixel, we have a missing pixel.
        if goalPixel? and not pixel?
          return true

        # Make sure the pixel doesn't match the background color.
        else if backgroundColor
          pixelIntegerDirectColor = if pixel.paletteColor then @_paletteToIntegerDirectColor pixel.paletteColor else @_directToIntegerDirectColor pixel.directColor
          return true if EJSON.equals pixelIntegerDirectColor, backgroundColor.integerDirectColor

    false
  
  @resetDelayOnOperationExecuted: -> false
  
  getEditor: -> @constructor.getEditor()
  getActiveAsset: -> @constructor.getActiveAsset()

  onActivate: ->
    super arguments...
  
    if @constructor.resetDelayOnOperationExecuted()
      # Start listening to actions done on the asset.
      @bitmapId = @constructor.getActiveAsset().bitmapId()
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, @onOperationExecuted

  onDeactivate: ->
    super arguments...
  
    if @constructor.resetDelayOnOperationExecuted()
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandlers @

  onOperationExecuted: (document, operation, changedFields) ->
    return unless document._id is @bitmapId
  
    @resetDelay()
