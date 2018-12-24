AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Redo extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Redo'
  @displayName: -> "Redo"
      
  @initialize()

  enabled: ->
    return unless assetData = @interface.parent.assetData()
    assetData.historyPosition < assetData.history?.length

  execute: ->
    assetData = @interface.parent.assetData()
    return unless assetData.historyPosition < assetData.history?.length

    LOI.Assets.VisualAsset.redo @interface.parent.assetClassName, assetData._id
