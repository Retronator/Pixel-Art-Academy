AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

PAA.Practice.Challenges.Drawing.TutorialSprite.reset.method (assetId, spriteId) ->
  check assetId, String
  check spriteId, Match.DocumentId

  # Build the original state.
  assetClass = PAA.Practice.Project.Asset.getClassForId assetId

  resetPixels = (pixels) ->
    # Replace pixels in this sprite.
    LOI.Assets.Sprite.replacePixels spriteId, 0, pixels

    # Clear the history.
    LOI.Assets.VisualAsset.clearHistory LOI.Assets.Sprite.className, spriteId

  if bitmapString = assetClass.bitmapString()
    resetPixels assetClass.createPixelsfromBitmapString bitmapString

  else if imageUrl = assetClass.imageUrl()
    # Note: We're on the client and need to send a callback that will execute once the image has loaded.
    assetClass.createPixelsFromImageUrl imageUrl, resetPixels
