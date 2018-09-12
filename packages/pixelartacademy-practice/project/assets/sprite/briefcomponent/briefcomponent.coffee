AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.BriefComponent'

  constructor: (@sprite) ->
    super
    
  onCreated: ->
    super
    
    @parent = @ancestorComponentWith 'editAsset'

    @autorun (computation) =>
      return unless palette = @sprite.sprite()?.palette
      LOI.Assets.Palette.forId.subscribe @, palette._id

    @palette = new ComputedField =>
      return unless palette = @sprite.sprite()?.palette
      LOI.Assets.Palette.documents.findOne palette._id

  needsSettingsSelection: ->
    not (PAA.PixelBoy.Apps.Drawing.state('editorId') or PAA.PixelBoy.Apps.Drawing.state('externalSoftware'))

  needsToolsChallenge: ->
    true

  noActions: ->
    not (@canEdit() or @canUpload())

  canEdit: ->
    # Editor needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('editorId')

    PAA.Practice.Project.Asset.Sprite.state 'canEdit'

  canUpload: ->
    # External software needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('externalSoftware')

    PAA.Practice.Project.Asset.Sprite.state 'canUpload'

  customPaletteColorsString: ->
    count = 0
    count += ramp.shades.length for ramp in @sprite.customPalette().ramps

    "#{count} color#{if count > 1 then 's' else ''}"

  spriteImageFileName: ->
    _.kebabCase @sprite.displayName()

  events: ->
    super.concat
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
          sprite = @parent.asset()

          if fixedDimensions = sprite.fixedDimensions()
            # Make sure the dimensions match.
            unless image.width is fixedDimensions.width and image.height is fixedDimensions.height
              # Report the mismatch to the player.
              LOI.adventure.showActivatableModalDialog
                dialog: new LOI.Components.Dialog
                  message: "The size of the uploaded image (#{image.width}×#{image.height}) does not match
                            the required sprite size (#{fixedDimensions.width}×#{fixedDimensions.height})."
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
    editor = @parent.drawing.editor()
    spriteData = editor.spriteData()
    palette = spriteData.customPalette or LOI.Assets.Palette.documents.findOne spriteData.palette._id

    # See if we have a background color defined.
    backgroundColor = @sprite.constructor.backgroundColor()

    if backgroundColor?.paletteColor
      # Map palette color to a direct color so we can calculate distance to it.
      backgroundColor = palette.ramps[backgroundColor.paletteColor.ramp].shades[backgroundColor.paletteColor.shade]

    pixels = @_createPixels imageData, palette, backgroundColor
      
    LOI.Assets.Sprite.replacePixels @sprite.spriteId(), 0, pixels

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
          closestRamp = null
          closestShade = null
          smallestColorDistance = if backgroundColor then @_colorDistance backgroundColor, r, g, b else 3
    
          for ramp, rampIndex in palette.ramps
            for shade, shadeIndex in ramp.shades
              distance = @_colorDistance shade, r, g, b
    
              if distance < smallestColorDistance
                smallestColorDistance = distance
                closestRamp = rampIndex
                closestShade = shadeIndex
      
          # If we found a palette color, add the pixel.
          if closestRamp? and closestShade?
            pixel =
              x: x
              y: y
              paletteColor:
                ramp: closestRamp
                shade: closestShade
              
        else
          pixel =
            x: x
            y: y
            directColor: {r, g, b}

        pixels.push pixel if pixel
        
    pixels
      
  _colorDistance: (color, r, g, b) ->
    Math.abs(color.r - r) + Math.abs(color.g - g) + Math.abs(color.b - b)
