AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Undo extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Undo'
  @displayName: -> "Undo"

  @initialize()

  enabled: ->
    return unless asset = @asset()
    asset.historyPosition

  execute: ->
    asset = @asset()
    LOI.Assets.VisualAsset.undo asset.constructor.className, asset._id, asset.lastEditTime or asset.creationTime, new Date, (error, result) ->
      AM.Document.Versioning.reportExecuteActionError asset if error

class LOI.Assets.Editor.Actions.Redo extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Redo'
  @displayName: -> "Redo"
  
  @initialize()

  enabled: ->
    return unless asset = @asset()
    asset.historyPosition < asset.history?.length

  execute: ->
    asset = @asset()
    LOI.Assets.VisualAsset.redo asset.constructor.className, asset._id, asset.lastEditTime or asset.creationTime, new Date, (error, result) ->
      AM.Document.Versioning.reportExecuteActionError asset if error
