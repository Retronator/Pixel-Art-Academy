AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent extends PAA.Practice.Project.Asset.Sprite.BriefComponent
  @register 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent'

  canEdit: ->
    PAA.PixelBoy.Apps.Drawing.state('editorId')?

  canUpload: ->
    PAA.PixelBoy.Apps.Drawing.state('externalSoftware')?

  processUploadData: (imageData) ->
    # Put the sprite into upload mode.
    @sprite.uploadMode true

    # Clone current sprite data so we can manipulate it directly.
    editor = @parent.drawing.editor()
    spriteData = _.cloneDeep @sprite.sprite()
    editor.manualSpriteData spriteData
    @sprite.manualUserSpriteData spriteData
    @sprite.engineComponent.drawMissingPixelsUpTo x: -1, y: -1

    # Open the editor and zoom in the sprite as much as possible.
    editor.manuallyActivated true

    scaleSprite = =>
      scale = LOI.adventure.interface.display.scale()

      viewport = LOI.adventure.interface.display.viewport()

      clipboardSpriteSize = @parent.assetSize()
      borderWidth = clipboardSpriteSize.borderWidth / clipboardSpriteSize.scale

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
    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

    # See if we have a background color defined.
    backgroundColor = @sprite.constructor.backgroundColor()

    if backgroundColor?.paletteColor
      # Map palette color to a direct color so we can calculate distance to it.
      backgroundColor = palette.ramps[backgroundColor.paletteColor.ramp].shades[backgroundColor.paletteColor.shade]

    # Create target pixels.
    pixels = @_createPixels imageData, palette, backgroundColor

    replacePixel = (x, y) =>
      existingPixelIndex = _.findIndex spriteData.layers[0].pixels, (pixel) => pixel.x is x and pixel.y is y
      newPixel = _.find pixels, (pixel) => pixel.x is x and pixel.y is y

      if newPixel
        # This is a full pixel so color it.
        if existingPixelIndex > -1
          # Replace data in existing pixel.
          spriteData.layers[0].pixels[existingPixelIndex] = newPixel

        else
          # Add new pixel.
          spriteData.layers[0].pixels.push newPixel

      else if existingPixelIndex > -1
        # This should be an empty pixel so remove it.
        spriteData.layers[0].pixels.splice existingPixelIndex, 1

      # Re-set sprite data to force image refresh.
      editor.manualSpriteData spriteData
      @sprite.manualUserSpriteData spriteData

      @sprite.engineComponent.drawMissingPixelsUpTo {x, y}

      # Move to next pixel.
      x++

      if x is imageData.width
        x = 0
        y++

        if y is imageData.height
          # We have reached the end.
          updateSprite()
          return

      Meteor.setTimeout =>
        replacePixel x, y
      ,
        pixelDrawDelay

    updateSprite = =>
      LOI.Assets.Sprite.replacePixels @sprite.spriteId(), 0, spriteData.layers[0].pixels, (error) =>
        if error
          console.error error
          return

        editor.manualSpriteData null
        @sprite.manualUserSpriteData null

        # Mark this asset as uploaded.
        assets = @sprite.tutorial.state 'assets'
        spriteId = @sprite.id()

        assets = [] unless assets
        asset = _.find assets, (asset) => asset.id is spriteId

        unless asset
          asset = id: @id()
          assets.push asset

        asset.uploaded = true

        @sprite.tutorial.state 'assets', assets

    Meteor.setTimeout =>
      scaleSprite()

      Meteor.setTimeout =>
        replacePixel 0, 0
      ,
        500
    ,
      1000

  onClickEditButton: (event) ->
    # Make sure sprite is not in upload mode.
    @sprite.uploadMode false

    # Don't show missing pixels.
    @sprite.engineComponent.drawMissingPixelsUpTo x: -1, y: -1

    super arguments...
