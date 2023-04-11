AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent extends PAA.Practice.Project.Asset.Bitmap.BriefComponent
  @register 'PixelArtAcademy.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent'

  canEdit: ->
    PAA.PixelBoy.Apps.Drawing.state('editorId')?

  canUpload: ->
    PAA.PixelBoy.Apps.Drawing.state('externalSoftware')?

  processUploadData: (imageData) ->
    # Put the bitmap into upload mode.
    @bitmap.uploadMode true

    # Clone current bitmap data so we can manipulate it directly.
    editor = @parent.drawing.editor()
    bitmapData = _.cloneDeep @bitmap.bitmap()
    editor.manualBitmapData bitmapData
    @bitmap.manualUserBitmapData bitmapData
    @bitmap.engineComponent.drawMissingPixelsUpTo x: -1, y: -1

    # Open the editor and zoom in the bitmap as much as possible.
    editor.manuallyActivated true

    scaleBitmap = =>
      scale = LOI.adventure.interface.display.scale()

      viewport = LOI.adventure.interface.display.viewport()

      clipboardBitmapSize = @parent.assetSize()
      borderWidth = clipboardBitmapSize.borderWidth / clipboardBitmapSize.scale

      maxWidth = viewport.viewportBounds.width() * 0.9
      maxHeight = viewport.viewportBounds.height() * 0.9

      imageWidth = imageData.width + 2 * borderWidth
      imageHeight = imageData.height + 2 * borderWidth

      widthScale = maxWidth / imageWidth / scale
      heightScale = maxHeight / imageHeight / scale

      maxScale = Math.min widthScale, heightScale
      scale = Math.floor maxScale

      pixelCanvas = editor.interface.getEditorForActiveFile()
      pixelCanvas.camera().setScale scale

    # Draw all pixels in 3 seconds.
    pixelDrawDelay = 3000 / (imageData.width * imageData.height)

    # Prepare colors.
    palette = bitmapData.customPalette or LOI.Assets.Palette.documents.findOne bitmapData.palette._id

    # See if we have a background color defined.
    backgroundColor = @bitmap.constructor.backgroundColor()

    if backgroundColor?.paletteColor
      # Map palette color to a direct color so we can calculate distance to it.
      backgroundColor = palette.ramps[backgroundColor.paletteColor.ramp].shades[backgroundColor.paletteColor.shade]

    # Create target pixels.
    pixels = @_createPixels imageData, palette, backgroundColor

    replacePixel = (x, y) =>
      existingPixelIndex = _.findIndex bitmapData.layers[0].pixels, (pixel) => pixel.x is x and pixel.y is y
      newPixel = _.find pixels, (pixel) => pixel.x is x and pixel.y is y

      if newPixel
        # This is a full pixel so color it.
        if existingPixelIndex > -1
          # Replace data in existing pixel.
          bitmapData.layers[0].pixels[existingPixelIndex] = newPixel

        else
          # Add new pixel.
          bitmapData.layers[0].pixels.push newPixel

      else if existingPixelIndex > -1
        # This should be an empty pixel so remove it.
        bitmapData.layers[0].pixels.splice existingPixelIndex, 1

      # Re-set bitmap data to force image refresh.
      editor.manualBitmapData bitmapData
      @bitmap.manualUserBitmapData bitmapData

      @bitmap.engineComponent.drawMissingPixelsUpTo {x, y}

      # Move to next pixel.
      x++

      if x is imageData.width
        x = 0
        y++

        if y is imageData.height
          # We have reached the end.
          updateBitmap()
          return

      Meteor.setTimeout =>
        replacePixel x, y
      ,
        pixelDrawDelay

    updateBitmap = =>
      LOI.Assets.Bitmap.replacePixels @bitmap.bitmapId(), 0, bitmapData.layers[0].pixels, (error) =>
        if error
          console.error error
          return

        editor.manualBitmapData null
        @bitmap.manualUserBitmapData null

        # Mark this asset as uploaded.
        assets = @bitmap.tutorial.state 'assets'
        bitmapId = @bitmap.id()

        assets = [] unless assets
        asset = _.find assets, (asset) => asset.id is bitmapId

        unless asset
          asset = id: @id()
          assets.push asset

        asset.uploaded = true

        @bitmap.tutorial.state 'assets', assets

    Meteor.setTimeout =>
      scaleBitmap()

      Meteor.setTimeout =>
        replacePixel 0, 0
      ,
        500
    ,
      1000

  onClickEditButton: (event) ->
    # Make sure bitmap is not in upload mode.
    @bitmap.uploadMode false

    # Don't show missing pixels.
    @bitmap.engineComponent.drawMissingPixelsUpTo x: -1, y: -1

    super arguments...
