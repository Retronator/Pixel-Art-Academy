PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Challenges.Drawing.TutorialSprite extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @createSprite: (characterId) ->
    palette = LOI.Assets.Palette.documents.findOne name: @restrictedPaletteName()
    
    size = @fixedDimensions()
    
    spriteData =
      palette: _.pick palette, '_id'
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
