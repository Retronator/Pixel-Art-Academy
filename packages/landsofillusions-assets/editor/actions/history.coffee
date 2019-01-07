AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class HistoryAction extends FM.Action
  assetData: -> @interface.getEditorForActiveFile()?.assetData()

class LOI.Assets.Editor.Actions.Undo extends HistoryAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Undo'
  @displayName: -> "Undo"

  @initialize()

  enabled: ->
    return unless assetData = @assetData()
    assetData.historyPosition

  execute: ->
    return unless assetData = @assetData()
    LOI.Assets.VisualAsset.undo @interface.parent.assetClassName, assetData._id

class LOI.Assets.Editor.Actions.Redo extends HistoryAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Redo'
  @displayName: -> "Redo"
      
  @initialize()

  enabled: ->
    return unless assetData = @assetData()
    assetData.historyPosition < assetData.history?.length

  execute: ->
    return unless assetData = @assetData()
    LOI.Assets.VisualAsset.redo @interface.parent.assetClassName, assetData._id
