AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Asset.insert.method (assetClassName) ->
  check assetClassName, String

  RA.authorizeAdmin()
  
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  assetClass.documents.insert
    creationTime: new Date()
  
LOI.Assets.Asset.insertVersioned.method (assetClassName) ->
  check assetClassName, String
  
  RA.authorizeAdmin()
  
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  assetClass.documents.insert
    versioned: true
    creationTime: new Date()

LOI.Assets.Asset.update.method (assetClassName, assetId, update, options) ->
  check assetClassName, String
  check assetId, Match.DocumentId
  check update, Object
  check options, Match.Optional Object

  RA.authorizeAdmin()
  
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  assetClass.documents.update assetId, update, options

LOI.Assets.Asset.remove.method (assetClassName, assetId) ->
  check assetClassName, String
  check assetId, Match.DocumentId

  RA.authorizeAdmin()
  
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  assetClass.documents.remove assetId

LOI.Assets.Asset.duplicate.method (assetClassName, assetId) ->
  check assetClassName, String
  check assetId, Match.DocumentId

  RA.authorizeAdmin()

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  asset = LOI.Assets.Asset._requireAsset assetId, assetClass

  # Move desired properties to a plain object.
  duplicate = {}

  for own key, value of asset when not (key in ['name', '_id', '_schema'])
    duplicate[key] = value

  assetClass.documents.insert duplicate

LOI.Assets.Asset.exists.method (assetClassName, assetId) ->
  check assetClassName, String
  check assetId, Match.DocumentId

  RA.authorizeAdmin()

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  assetClass.documents.findOne(assetId)?

LOI.Assets.Asset.getData.method (assetClassName, assetId, fields) ->
  check assetClassName, String
  check assetId, Match.DocumentId
  check fields, Match.OptionalOrNull Object

  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  assetClass.documents.findOne assetId, {fields}
