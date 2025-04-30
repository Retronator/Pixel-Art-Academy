AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanConstructionLinesStep extends TutorialBitmap.Step
  completed: ->
    return unless super arguments...
    
    # Make sure all pixels are the first ramp.
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        continue unless pixel = bitmapLayer.getPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
        return false if pixel.paletteColor.ramp

    true

  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    bitmapLayer = bitmap.layers[0]
    
    pixels = []
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        continue unless pixel = bitmapLayer.getPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
        continue unless pixel.paletteColor.ramp
        pixels.push {x, y}
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date

  drawOverlaidHints: (context, renderOptions) ->
    @_prepareColorHelp context, renderOptions
    
    bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        continue unless pixel = bitmapLayer.getPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
        continue unless pixel.paletteColor.ramp

        @_drawColorHelpForPixel context, x, y, null, null, null, renderOptions
    
    # Explicit return to avoid result collection.
    return
