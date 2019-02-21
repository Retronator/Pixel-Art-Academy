AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Duplicate extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Duplicate'
  @displayName: -> "Duplicate"

  @initialize()
    
  execute: ->
    asset = @asset()
    
    LOI.Assets.Asset.duplicate asset.constructor.className, asset._id, (error, duplicateAssetId) =>
      if error
        console.error error
        return

      # Open the duplicate.
      editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
      editorView.addFile duplicateAssetId

