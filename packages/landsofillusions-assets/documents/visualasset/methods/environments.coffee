AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.VisualAsset.addEnvironmentByUrl.method (assetClassName, assetId, characterId, url, displayed) ->
  check assetId, Match.DocumentId
  check assetClassName, String
  check characterId, Match.OptionalOrNull Match.DocumentId
  check url, String
  check displayed, Match.OptionalOrNull Boolean

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  # Create the image document.
  imageId = LOI.Assets.Image.insert characterId, url

  environment =
    image:
      _id: imageId
      # Also inject the URL so we don't have to wait for environment to kick in.
      url: url

  environment[key] = value for key, value of {displayed} when value?

  # Add the environment.
  assetClass.documents.update assetId,
    $push:
      environments: environment

  # Return created image ID.
  imageId

LOI.Assets.VisualAsset.activateEnvironment.method (assetClassName, assetId, imageId) ->
  check assetClassName, String
  check assetId, Match.DocumentId
  check imageId, Match.OptionalOrNull Match.DocumentId

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  # Set all environments' active to false, except the one with chosen image (or none).
  updatedValues = {}

  if imageId
    activeEnvironmentIndex = _.findIndex asset.environments, (environment) -> environment.image._id is imageId
    throw new AE.ArgumentException "Image is not one of the environments." if activeEnvironmentIndex is -1

  for environment, index in asset.environments
    newActiveValue = index is activeEnvironmentIndex

    unless environment.active is newActiveValue
      updatedValues["environments.#{index}.active"] = newActiveValue

  throw new AE.ArgumentException "No changes were necessary." unless _.keys(updatedValues).length

  assetClass.documents.update assetId,
    $set: updatedValues
