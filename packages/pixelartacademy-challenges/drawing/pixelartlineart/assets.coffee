LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawLineArt = PAA.Challenges.Drawing.PixelArtLineArt.DrawLineArt
PADB = PixelArtDatabase

assets =
  MickeyMouseSoundCartoon:
    dimensions: -> width: 64, height: 32
    imageName: -> 'mickeymousesoundcartoon'
    bitmapInfo: -> """
      Fan art based on Mickey Mouse Sound Cartoons, Ub Iwerks, 1928.
    """

  SuperMarioBros3World5:
    dimensions: -> width: 64, height: 32
    imageName: -> 'supermariobros3world5'
    bitmapInfo: -> """
      Fan art based on Super Mario Bros. 3, Nintendo Power Strategy Guide (vol. SG1/NP13), Nintendo, 1990.
    """
    
  SonicTheHedgehog3:
    dimensions: -> width: 64, height: 32
    imageName: -> 'sonicthehedgehog3'
    bitmapInfo: -> """
      Fan art based on Sonic the Hedgehog 3, Sega, 1994.
    """

for assetId, asset of assets
  do (assetId, asset) ->
    class DrawLineArt[assetId] extends DrawLineArt
      @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.DrawLineArt.#{assetId}"
      @fixedDimensions: asset.dimensions
      @backgroundColor: -> null
      @imageName: asset.imageName
      @bitmapInfo: asset.bitmapInfo
      @maxClipboardScale: asset.maxClipboardScale
      @initialize()
  
    PAA.Challenges.Drawing.PixelArtLineArt.drawLineArtClasses[assetId] = DrawLineArt[assetId]