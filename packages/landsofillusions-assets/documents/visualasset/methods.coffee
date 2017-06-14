RA = Retronator.Accounts
LOI = LandsOfIllusions

requireAssetClass = (assetClassName) ->
  assetClass = LOI.Assets[assetClassName]
  throw new AE.ArgumentException "Asset class name doesn't exist." unless assetClass

  assetClass

requireAsset = (assetId, assetClass) ->
  asset = assetClass.documents.findOne assetId
  throw new AE.ArgumentException "Asset does not exist." unless asset

  asset

LOI.Assets.VisualAsset.updatePalette.method (assetId, assetClassName, paletteId) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check paletteId, Match.DocumentId

  RA.authorizeAdmin()

  assetClass = requireAssetClass assetClassName
  requireAsset assetId, assetClass

  # Make sure the palette exists.
  palette = LOI.Assets.Palette.documents.findOne paletteId
  throw new AE.ArgumentException "Palette doesn't exist." unless palette

  assetClass.documents.update assetId,
    $set:
      "palette._id": paletteId

LOI.Assets.VisualAsset.updateMaterial.method (assetId, assetClassName, index, materialUpdate) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer
  check materialUpdate, Match.OptionalOrNull Match.ObjectIncluding
    name: Match.OptionalOrNull String
    ramp: Match.OptionalOrNull Match.Integer
    shade: Match.OptionalOrNull Match.Integer
    dither: Match.OptionalOrNull Number

  RA.authorizeAdmin()

  assetClass = requireAssetClass assetClassName
  asset = requireAsset assetId, assetClass

  asset = assetClass.documents.findOne assetId
  throw new AE.ArgumentException "Asset does not exist." unless asset

  # Get existing color or create new entry.
  material = asset.materials?[index] or {}

  # Update the fields that are set. (We don't use extend because that introduces null values.)
  if materialUpdate
    for key, value of materialUpdate
      material[key] = value if value?

  assetClass.documents.update assetId,
    $set:
      "materials.#{index}": material
