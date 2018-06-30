AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.VisualAsset.undo.method (assetClassName, assetId) ->
  check assetId, Match.DocumentId
  check assetClassName, String

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.VisualAsset._authorizeAssetAction asset

  # Find history entry.
  throw new AE.InvalidOperationException "There is nothing to undo." unless asset.historyPosition
  throw new AE.InvalidOperationException "History position does not exist." unless asset.history?[asset.historyPosition - 1]

  history = EJSON.parse asset.history[asset.historyPosition - 1]

  # Create the modifier that will undo the change at this position.
  modifier = history.backward

  # Decrease history position.
  modifier.$set ?= {}
  modifier.$set.historyPosition = asset.historyPosition - 1

  assetClass.documents.update assetId, modifier

LOI.Assets.VisualAsset.redo.method (assetClassName, assetId) ->
  check assetId, Match.DocumentId
  check assetClassName, String

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.VisualAsset._authorizeAssetAction asset

  # Find history entry.
  throw new AE.InvalidOperationException "There is nothing to redo." unless asset.historyPosition < asset.history.length
  throw new AE.InvalidOperationException "History position does not exist." unless asset.history?[asset.historyPosition]

  history = EJSON.parse asset.history[asset.historyPosition]

  # Create the modifier that will undo the change at this position.
  modifier = history.forward

  # Decrease history position.
  modifier.$set ?= {}
  modifier.$set.historyPosition = asset.historyPosition + 1

  assetClass.documents.update assetId, modifier

LOI.Assets.VisualAsset.clearHistory.method (assetClassName, assetId) ->
  check assetId, Match.DocumentId
  check assetClassName, String

  # Authorize action.
  assetClass = LOI.Assets.VisualAsset._requireAssetClass assetClassName
  asset = LOI.Assets.VisualAsset._requireAsset assetId, assetClass
  LOI.Assets.VisualAsset._authorizeAssetAction asset

  assetClass.documents.update assetId,
    $set:
      history: []
      historyPosition: 0
