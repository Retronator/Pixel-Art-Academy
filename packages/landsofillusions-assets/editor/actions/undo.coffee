AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Undo extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Undo'
  @displayName: -> "Undo"

  @initialize()
    
  enabled: ->
    return unless assetData = @interface.parent.assetData()
    assetData.historyPosition

  execute: ->
    assetData = @interface.parent.assetData()
    return unless assetData.historyPosition

    LOI.Assets.VisualAsset.undo @interface.parent.assetClassName, assetData._id
