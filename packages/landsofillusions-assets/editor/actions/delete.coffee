AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Delete extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Delete'
  @displayName: -> "Delete"

  @initialize()
    
  execute: ->
    asset = @asset()

    # First remove it from the UI so that subscriptions get stopped.
    editorView = @interface.getEditorViewForFile asset._id
    editorView.removeFile asset._id

    Tracker.afterFlush =>
      # Now also remove it in the database.
      LOI.Assets.Asset.remove asset.constructor.className, asset._id
