AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Bitmap.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Bitmap.BriefComponent'

  constructor: (@bitmap) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    @parent = @ancestorComponentWith 'editAsset'

    @autorun (computation) =>
      return unless palette = @bitmap.bitmap()?.palette
      LOI.Assets.Palette.forId.subscribeContent @, palette._id

    @palette = new ComputedField =>
      return unless palette = @bitmap.bitmap()?.palette
      LOI.Assets.Palette.documents.findOne palette._id

  needsSettingsSelection: ->
    not (PAA.PixelPad.Apps.Drawing.state('editorId') or PAA.PixelPad.Apps.Drawing.state('externalSoftware'))

  needsToolsChallenge: ->
    true

  noActions: ->
    not (@canEdit() or @canUpload())

  canEdit: -> PAA.PixelPad.Apps.Drawing.canEdit()
  canUpload: -> PAA.PixelPad.Apps.Drawing.canUpload()

  customPaletteColorsString: ->
    count = 0
    count += ramp.shades.length for ramp in @bitmap.customPalette().ramps

    "#{count} color#{if count > 1 then 's' else ''}"

  bitmapImageFileName: ->
    _.kebabCase @bitmap.displayName()

  events: ->
    super(arguments...).concat
      'click .edit-button': @onClickEditButton
      'click .assets-button': @onClickAssetsButton
      'click .upload-button': @onClickUploadButton

  onClickEditButton: (event) ->
    @parent.editAsset()

  onClickAssetsButton: (event) ->
    @parent.showSecondPage()

  onClickUploadButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      # Load file.
      reader = new FileReader()
      reader.onload = (event) =>
        image = new Image
        image.onload = =>
          if fixedDimensions = @bitmap.fixedDimensions()
            # Make sure the dimensions match.
            unless image.width is fixedDimensions.width and image.height is fixedDimensions.height
              # Report the mismatch to the player.
              LOI.adventure.showActivatableModalDialog
                dialog: new LOI.Components.Dialog
                  message: "The size of the uploaded image (#{image.width}×#{image.height}) does not match
                            the required bitmap size (#{fixedDimensions.width}×#{fixedDimensions.height})."
                  buttons: [text: "OK"]

              return

          canvas = $('<canvas>')[0]
          canvas.width = image.width
          canvas.height = image.height
          context = canvas.getContext '2d'

          context.drawImage image, 0, 0

          imageData = context.getImageData 0, 0, canvas.width, canvas.height
          @processUploadData imageData

        image.src = event.target.result

      reader.readAsDataURL file

    $fileInput.click()

  processUploadData: (imageData) ->
    # Prepare for palette mapping.
    bitmapData = @bitmap.bitmap()
    palette = bitmapData.customPalette or LOI.Assets.Palette.documents.findOne bitmapData.palette._id

    # See if we have a background color defined.
    backgroundColor = @bitmap.constructor.backgroundColor()

    if backgroundColor?.paletteColor
      # Map palette color to a direct color so we can calculate distance to it.
      backgroundColor = palette.ramps[backgroundColor.paletteColor.ramp].shades[backgroundColor.paletteColor.shade]

    pixels = @_createPixels imageData, palette, backgroundColor
    
    LOI.Assets.Bitmap.replacePixels @bitmap.bitmapId(), 0, pixels

  _createPixels: (imageData, palette, backgroundColor) ->
    pixels = []
    
    for x in [0...imageData.width]
      for y in [0...imageData.height]
        pixelIndex = (x + y * imageData.width) * 4

        # Skip transparent pixels.
        a = imageData.data[pixelIndex + 3]
        continue unless a
    
        r = imageData.data[pixelIndex] / 255
        g = imageData.data[pixelIndex + 1] / 255
        b = imageData.data[pixelIndex + 2] / 255
        
        pixel = null
        
        # This is a full pixel. If we have a palette, find the closest palette color.
        if palette
          paletteColor = palette.closestPaletteColorFromRGB r, g, b, backgroundColor
      
          # If we found a palette color, add the pixel.
          if paletteColor
            pixel = {x, y, paletteColor}
            
        else
          pixel =
            x: x
            y: y
            directColor: {r, g, b}

        pixels.push pixel if pixel
        
    pixels
