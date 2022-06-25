PAA = PixelArtAcademy
LOI = LandsOfIllusions
PNG = Npm.require('pngjs').PNG
Request = request

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @createSprite: (characterId) ->
    size = @fixedDimensions()
    
    spriteData =
      creationTime: new Date()
      bounds:
        left: 0
        right: size.width - 1
        top: 0
        bottom: size.height - 1
        fixed: true
      authors: [
        _id: characterId
      ]
      name: @displayName()
      layers: [
        pixels: []
      ]

    if paletteName = @restrictedPaletteName()
      palette = LOI.Assets.Palette.documents.findOne name: paletteName
      spriteData.palette = _.pick palette, '_id'

    else if paletteImageUrl = @customPaletteImageUrl()
      paletteImageResponse = Request.getSync Meteor.absoluteUrl(paletteImageUrl), encoding: null

      png = PNG.sync.read paletteImageResponse.body
      ramps = []

      backgroundColorArray = @backgroundColor()?.toByteArray?()

      isBackground = (pixelOffset) ->
        # Treat transparent pixels as background.
        return true unless png.data[pixelOffset + 3]

        # We're not transparent, so in case we don't have a background color, this can't be a background pixel.
        return unless backgroundColorArray

        # Compare in case this pixel matches our background color.
        for attributeOffset in [0..2]
          return unless png.data[pixelOffset + attributeOffset] is backgroundColorArray[attributeOffset]

        # The match was made, this pixel has background color.
        true

      for y in [0...png.height]
        rampOffset = y * png.width * 4

        # We have a ramp if the first pixel is not background.
        continue if isBackground rampOffset

        shades = []

        for x in [0...png.width]
          shadeOffset = rampOffset + x * 4

          # We have no more shades after we reach a background pixel.
          break if isBackground shadeOffset

          shades.push
            r: png.data[shadeOffset] / 255
            g: png.data[shadeOffset + 1] / 255
            b: png.data[shadeOffset + 2] / 255

        ramps.push
          shades: shades

      spriteData.customPalette =
        ramps: ramps
        
    else if customPalette = @customPalette()
      spriteData.customPalette = customPalette

    if references = @references?()
      spriteData.references = []
  
      for reference in references
        # Allow sending in just the reference URL.
        if _.isString reference
          reference =
            image:
              url: reference

        imageUrl = reference.image.url

        # Ensure we have an image with this URL.
        imageId = LOI.Assets.Image.documents.findOne(url: imageUrl)?._id
        imageId ?= LOI.Assets.Image.documents.insert url: imageUrl

        reference.image._id = imageId

        spriteData.references.push reference
  
    LOI.Assets.Sprite.documents.insert spriteData
