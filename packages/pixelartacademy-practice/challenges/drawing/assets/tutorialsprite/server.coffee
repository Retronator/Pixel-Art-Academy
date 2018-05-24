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
  
    LOI.Assets.Sprite.documents.insert spriteData
