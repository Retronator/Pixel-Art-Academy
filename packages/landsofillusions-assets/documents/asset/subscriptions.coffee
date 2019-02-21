RA = Retronator.Accounts
LOI = LandsOfIllusions

# Subscription to a specific asset for use as game assets.
LOI.Assets.Asset.forName.publish (assetClassName, name) ->
  check assetClassName, String
  check name, String

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  assetClass.documents.find {name},
    fields:
      history: 0
      editor: 0

# Subscription to a specific asset by the player.
LOI.Assets.Asset.forId.publish (assetClassName, id) ->
  check assetClassName, String
  check id, Match.DocumentId

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  assetClass.documents.find id    

LOI.Assets.Asset.all.publish (assetClassName) ->
  # Only admins (and later editors) can see all the assets.
  RA.authorizeAdmin userId: @userId or null

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  # We only return asset names when subscribing to all so that we can list them.
  assetClass.documents.find {},
    fields:
      name: 1
