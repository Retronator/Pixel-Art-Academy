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
