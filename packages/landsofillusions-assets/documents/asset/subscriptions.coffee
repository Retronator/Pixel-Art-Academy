RA = Retronator.Accounts
LOI = LandsOfIllusions

# Subscription to a specific sprite.
LOI.Assets.Asset.forId.publish (assetClassName, id) ->
  check assetClassName, String
  check id, Match.DocumentId

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  assetClass.documents.find id

LOI.Assets.Asset.all.publish (assetClassName) ->
  # Only admins (and later sprite editors) can see all the sprite.
  RA.authorizeAdmin userId: @userId or null

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  # We only return sprite names when subscribing to all so that we can list them.
  assetClass.documents.find {},
    fields:
      name: 1
