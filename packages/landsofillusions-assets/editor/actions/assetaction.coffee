AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.AssetAction extends FM.Action
  enabled: -> @interface.activeFileId()?
  loader: -> @interface.getLoaderForActiveFile()
  asset: -> @loader()?.asset()
  editor: -> @interface.getEditorForActiveFile()
  editorView: -> @interface.getEditorViewForActiveFile()
