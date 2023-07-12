AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Instructions.Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
  @getActiveAssetOfType: (assetClass) ->
    # We must be in the editor on the provided asset.
    return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    return unless currentApp = pixelPad.os.currentApp()
    return unless currentApp instanceof PAA.PixelPad.Apps.Drawing
    drawing = currentApp

    return unless editor = drawing.editor()
    return unless editor.drawingActive()
    
    return unless asset = editor.activeAsset()
    return unless asset instanceof assetClass
    
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
    
          # If either of the pixels has a direct color, we need to translate the other one too.
          pixelIntegerDirectColor = if pixel.paletteColor then @_paletteToIntegerDirectColor pixel.paletteColor else @_directToIntegerDirectColor pixel.directColor
          return true unless EJSON.equals pixelIntegerDirectColor, backgroundColor.integerDirectColor

    false
