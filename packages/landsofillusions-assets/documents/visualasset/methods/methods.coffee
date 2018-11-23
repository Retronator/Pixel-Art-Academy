AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.VisualAsset.updatePalette.method (assetClassName, assetId, paletteId) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check paletteId, Match.DocumentId

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  # Make sure the palette exists.
  palette = LOI.Assets.Palette.documents.findOne paletteId
  throw new AE.ArgumentException "Palette doesn't exist." unless palette

  assetClass.documents.update assetId,
    $set:
      "palette._id": paletteId

LOI.Assets.VisualAsset.updateMaterial.method (assetClassName, assetId, index, materialUpdate) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer
  check materialUpdate, Match.OptionalOrNull Match.ObjectIncluding
    name: Match.OptionalOrNull String
    ramp: Match.OptionalOrNull Match.Integer
    shade: Match.OptionalOrNull Match.Integer
    dither: Match.OptionalOrNull Number

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  # Get existing material or create new entry.
  material = asset.materials?[index] or {}

  # Update the fields that are set. (We don't use extend because that introduces null values.)
  if materialUpdate
    for key, value of materialUpdate
      material[key] = value if value?

  assetClass.documents.update assetId,
    $set:
      "materials.#{index}": material

LOI.Assets.VisualAsset.updateLandmark.method (assetClassName, assetId, index, landmarkUpdate) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer
  check landmarkUpdate, Match.OptionalOrNull Match.ObjectIncluding
    name: Match.OptionalOrNull String
    x: Match.OptionalOrNull Number
    y: Match.OptionalOrNull Number
    z: Match.OptionalOrNull Number

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  # If we don't have landmarks at all, we create it as an array
  # so that sets will create index entries not object properties.
  unless asset.landmarks
    assetClass.documents.update assetId,
      $set:
        landmarks: []

  # Get existing landmark or create new entry.
  landmark = asset.landmarks?[index] or {}

  # Update the fields that are set. (We don't use extend because that introduces null values.)
  if landmarkUpdate
    for key, value of landmarkUpdate
      landmark[key] = value if value?

  assetClass.documents.update assetId,
    $set:
      "landmarks.#{index}": landmark

LOI.Assets.VisualAsset.reorderLandmark.method (assetClassName, assetId, index, newIndex) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer
  check newIndex, Match.Integer

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  movingLandmark = asset.landmarks?[index]
  throw new AE.ArgumentException "Asset does not have the landmark." unless movingLandmark

  asset.landmarks.splice index, 1
  asset.landmarks.splice newIndex, 0, movingLandmark

  assetClass.documents.update assetId,
    $set:
      landmarks: asset.landmarks

LOI.Assets.VisualAsset.removeLandmark.method (assetClassName, assetId, index) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check index, Match.Integer

  RA.authorizeAdmin()

  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass

  removingLandmark = asset.landmarks?[index]
  throw new AE.ArgumentException "Asset does not have the landmark." unless removingLandmark

  asset.landmarks.splice index, 1

  assetClass.documents.update assetId,
    $set:
      landmarks: asset.landmarks
