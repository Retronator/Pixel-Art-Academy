LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawLineArt = PAA.Challenges.Drawing.PixelArtLineArt.DrawLineArt
PADB = PixelArtDatabase

assets =
  MickeyMouseSoundCartoon:
    dimensions: -> width: 100, height: 120
    imageName: -> 'mickeymousesoundcartoon'
    bitmapInfo: -> """
      Fan art study based on Mickey Mouse Sound Cartoon (Ub Iwerks, 1928).
    """

  SuperMarioBros3World5:
    dimensions: -> width: 100, height: 100
    imageName: -> 'supermariobros3world5'
    bitmapInfo: -> """
      Fan art study based on Super Mario Bros. 3 (Nintendo Power Strategy Guide, vol. SG1/NP13, Nintendo, 1990).
    """
  
  SonicTheHedgehog3:
    dimensions: -> width: 80, height: 100
    imageName: -> 'sonicthehedgehog3'
    bitmapInfo: -> """
      Fan art study based on Sonic the Hedgehog 3 (Sega, 1994).
    """
    
  TetrisGameBoy:
    dimensions: -> width: 180, height: 200
    imageName: -> 'tetrisgameboy'
    bitmapInfo: -> """
      Fan art study based on Tetris (Game Boy, Nintendo, 1989).
    """
    binderScale: 0.5
  
  Rayman:
    dimensions: -> width: 65, height: 100
    imageName: -> 'rayman'
    bitmapInfo: -> """
      Fan art study based on Rayman (Ubisoft, 1995).
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
      @binderScale: -> asset.binderScale or super arguments...
      @initialize()
  
    PAA.Challenges.Drawing.PixelArtLineArt.drawLineArtClasses[assetId] = DrawLineArt[assetId]
