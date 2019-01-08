AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Delete extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Delete'
  @displayName: -> "Delete"

  @initialize()
    
  execute: ->
    asset = @asset()
    LOI.Assets.Asset.remove asset.constructor.className, asset._id
