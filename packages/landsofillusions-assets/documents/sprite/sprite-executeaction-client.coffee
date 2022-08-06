AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

# Hijack execute action methods that tools use and wire them into old method calls.
LOI.Assets.Sprite.executeAction = (assetClassName, assetId, action) ->


LOI.Assets.Sprite.executePartialAction = (assetClassName, assetId, action) ->

