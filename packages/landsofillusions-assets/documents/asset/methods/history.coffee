AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Asset.undo.method (assetClassName, assetId) ->
  check assetId, Match.DocumentId
  check assetClassName, String

  # Authorize action.
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  asset = LOI.Assets.Asset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  # Find history entry.
  throw new AE.InvalidOperationException "There is nothing to undo." unless asset.historyPosition
  throw new AE.InvalidOperationException "History position does not exist." unless asset.history?[asset.historyPosition - 1]

  history = EJSON.parse asset.history[asset.historyPosition - 1]

  # Create the modifier that will undo the change at this position.
  modifier = history.backward

  # See if this is part of a connected step.
  if modifier.connected
    delete modifier.connected
    connected = true

  # Decrease history position.
  modifier.$set ?= {}
  modifier.$set.historyPosition = asset.historyPosition - 1

  assetClass.documents.update assetId, modifier

  # Apply connected undo.
  LOI.Assets.Asset.undo assetClassName, assetId if connected

LOI.Assets.Asset.redo.method (assetClassName, assetId) ->
  check assetId, Match.DocumentId
  check assetClassName, String

  # Authorize action.
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  asset = LOI.Assets.Asset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  # Find history entry.
  throw new AE.InvalidOperationException "There is nothing to redo." unless asset.historyPosition < asset.history.length
  throw new AE.InvalidOperationException "History position does not exist." unless asset.history?[asset.historyPosition]

  history = EJSON.parse asset.history[asset.historyPosition]

  # Create the modifier that will undo the change at this position.
  modifier = history.forward

  # See if this is part of a connected step.
  if modifier.connected
    delete modifier.connected
    connected = true

  # Decrease history position.
  modifier.$set ?= {}
  modifier.$set.historyPosition = asset.historyPosition + 1

  assetClass.documents.update assetId, modifier

  # Apply connected redo.
  LOI.Assets.Asset.redo assetClassName, assetId if connected

LOI.Assets.Asset.clearHistory.method (assetClassName, assetId) ->
  check assetId, Match.DocumentId
  check assetClassName, String

  # Authorize action.
  assetClass = LOI.Assets.Asset._requireAssetClass assetClassName
  asset = LOI.Assets.Asset._requireAsset assetId, assetClass
  LOI.Assets.Asset._authorizeAssetAction asset

  assetClass.documents.update assetId,
    $set:
      history: []
      historyPosition: 0
