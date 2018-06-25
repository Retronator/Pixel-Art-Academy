PAA = PixelArtAcademy
LOI = LandsOfIllusions
PNG = Npm.require('pngjs').PNG
Request = request

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @createSprite: (characterId) ->
    size = @fixedDimensions()
    
    spriteData =
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

      for y in [0...png.height]
        rampOffset = y * png.width * 4

        # We have a ramp if the first pixel is not transparent.
        continue unless png.data[rampOffset + 3]

        shades = []

        for x in [0...png.width]
          shadeOffset = rampOffset + x * 4

          # We have no more shades after we reach a transparent pixel.
          break unless png.data[shadeOffset + 3]

          shades.push
            r: png.data[shadeOffset] / 255
            g: png.data[shadeOffset + 1] / 255
            b: png.data[shadeOffset + 2] / 255

        ramps.push
          shades: shades

      spriteData.customPalette =
        ramps: ramps

    if references = @references?()
      spriteData.references = []
  
      for imageUrl in references
        # Ensure we have an image with this URL.
        imageId = LOI.Assets.Image.documents.findOne(url: imageUrl)?._id
        imageId ?= LOI.Assets.Image.documents.insert url: imageUrl

        spriteData.references.push
          image:
            _id: imageId
            url: imageUrl
  
    LOI.Assets.Sprite.documents.insert spriteData
