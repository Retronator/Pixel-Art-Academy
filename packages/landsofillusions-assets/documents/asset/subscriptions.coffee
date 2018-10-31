RA = Retronator.Accounts
LOI = LandsOfIllusions

# Subscription to a specific sprite.
LOI.Assets.Asset.forId.publish (assetClassName, id) ->
  check assetClassName, String
  check id, Match.DocumentId

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  assetClass.documents.find id,
    fields:
      editor: 0

# Subscription to a specific sprite.
LOI.Assets.Asset.forIdFull.publish (assetClassName, id) ->
  check assetClassName, String
  check id, Match.DocumentId

  # Only admins (and later editors) can get all the fields.
  RA.authorizeAdmin userId: @userId or null

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  assetClass.documents.find id

LOI.Assets.Asset.all.publish (assetClassName) ->
  # Only admins (and later editors) can see all the assets.
  RA.authorizeAdmin userId: @userId or null

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  # We only return sprite names when subscribing to all so that we can list them.
  assetClass.documents.find {},
    fields:
      name: 1
