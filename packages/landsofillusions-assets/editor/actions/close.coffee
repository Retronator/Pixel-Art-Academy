AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Close extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Close'
  @displayName: -> "Close"

  @initialize()
    
  execute: ->
    editorView = @interface.getEditorViewForActiveFile()
    editorView.removeFile @loader().fileId
