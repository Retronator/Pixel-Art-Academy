AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.VisualAsset.addReferenceByUrl.method (assetClassName, assetId, characterId, url, position, scale, displayed) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check characterId, Match.DocumentId
  check url, String
  check position, Match.OptionalOrNull
    x: Number
    y: Number
  check scale, Match.OptionalOrNull Number
  check displayed, Match.OptionalOrNull Boolean

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  # Create the image document.
  imageId = LOI.Assets.Image.insert characterId, url

  reference =
    image:
      _id: imageId
      # Also inject the URL so we don't have to wait for reference to kick in.
      url: url

  reference[key] = value for key, value of {position, scale, displayed} when value?

  # Add the reference.
  assetClass.documents.update assetId,
    $push:
      references: reference

  # Return created image ID.
  imageId

LOI.Assets.VisualAsset.updateReferenceScale.method (assetClassName, assetId, imageId, scale) ->
  check scale, Number

  updateReference assetClassName, assetId, imageId, 'scale', scale

LOI.Assets.VisualAsset.updateReferencePosition.method (assetClassName, assetId, imageId, position) ->
  check position,
    x: Number
    y: Number

  updateReference assetClassName, assetId, imageId, 'position', position

LOI.Assets.VisualAsset.updateReferenceDisplayed.method (assetClassName, assetId, imageId, displayed) ->
  check displayed, Boolean

  updateReference assetClassName, assetId, imageId, 'displayed', displayed

updateReference = (assetClassName, assetId, imageId, key, value) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check imageId, Match.DocumentId

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  referenceIndex = _.findIndex asset.references, (asset) -> asset.image._id is imageId
  throw new AE.ArgumentException "Image is not one of the references." if referenceIndex is -1

  assetClass.documents.update assetId,
    $set:
      "references.#{referenceIndex}.#{key}": value

LOI.Assets.VisualAsset.reorderReferenceToTop.method (assetClassName, assetId, imageId) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check imageId, Match.DocumentId

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  referenceIndex = _.findIndex asset.references, (reference) -> reference.image._id is imageId
  throw new AE.ArgumentException "Image is not one of the references." if referenceIndex is -1

  # Find current highest order.
  highestOrder = _.max _.map asset.references, (reference) -> reference.order or 0

  assetClass.documents.update assetId,
    $set:
      "references.#{referenceIndex}.order": highestOrder + 1
