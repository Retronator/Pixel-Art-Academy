AM = Artificial.Mirage
AMu = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

Bresenham = require('bresenham-zingl')

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PathStep extends TutorialBitmap.PathStep
  # Note: this value was chosen so that the minimum complete closed line will get colored to solve this step.
  @minimumSolutionPixelAlpha = 110

  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    palette = @tutorialBitmap.palette()

    width = @stepArea.bounds.width
    height = @stepArea.bounds.height
    pixelCount = width * height
    paletteColorsByPixelIndex = []

    temporaryCanvas = new AM.ReadableCanvas width, height
    temporaryCanvas.context.lineCap = 'round'
    temporaryCanvas.context.lineJoin = 'bevel'
    temporaryCanvas.context.fillStyle = 'black'
    temporaryCanvas.context.strokeStyle = 'black'

    collectPathPixels = (paletteColor) =>
      imageData = temporaryCanvas.getFullImageData()

      for pixelIndex in [0...pixelCount]
        # Use sufficiently covered canvas pixels as part of the solved path. Later
        # paths and strokes are allowed to replace colors that were already collected.
        paletteColorsByPixelIndex[pixelIndex] = paletteColor if imageData.data[pixelIndex * 4 + 3] >= @constructor.minimumSolutionPixelAlpha

      temporaryCanvas.context.clearRect 0, 0, width, height

    # Render all fills first.
    for path in @paths when path.fillColor
      continue unless paletteColor = palette.exactPaletteColor path.fillColor

      temporaryCanvas.context.fill path.path
      collectPathPixels paletteColor

    # Render all strokes afterwards so they override fills.
    temporaryCanvas.context.lineWidth = 1

    for path in @paths when path.strokeColor
      continue unless paletteColor = palette.exactPaletteColor path.strokeColor

      temporaryCanvas.context.stroke path.path
      
      for cornersForPart in path.cornersOfParts
        for corner in cornersForPart
          x = Math.floor corner.x
          y = Math.floor corner.y
          temporaryCanvas.context.fillRect x, y, 1, 1
          
      collectPathPixels paletteColor

    pixels = []

    for paletteColor, pixelIndex in paletteColorsByPixelIndex when paletteColor
      pixels.push
        x: pixelIndex % width + @stepArea.bounds.x
        y: Math.floor(pixelIndex / width) + @stepArea.bounds.y
        paletteColor: paletteColor
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AMu.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
