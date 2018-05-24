AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

PAA.Practice.Challenges.Drawing.TutorialSprite.reset.method (assetId, spriteId) ->
  check assetId, String
  check spriteId, Match.DocumentId

  # Build the original state.
  assetClass = PAA.Practice.Project.Asset.getClassForId assetId
  pixels = assetClass.createPixelsFromBitmap assetClass.bitmap()

  # Replace pixels in this sprite.
  LOI.Assets.Sprite.replacePixels spriteId, 0, pixels
