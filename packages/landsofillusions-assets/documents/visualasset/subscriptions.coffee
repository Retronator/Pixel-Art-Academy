RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.VisualAsset.allSystem.publish (assetClassName) ->
  # Only admins (and later editors) can see all the assets.
  RA.authorizeAdmin userId: @userId or null

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName

  # We only return asset names when subscribing to all so that we can list them.
  assetClass.documents.find
    authors: $exists: false
  ,
    fields:
      name: 1
