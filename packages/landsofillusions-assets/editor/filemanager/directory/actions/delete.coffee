AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.Delete extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.Delete'
  @displayName: -> "Delete"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    assets = directory.documents()

    for item in directory.selectedItems()
      if item instanceof LOI.Assets.Editor.FileManager.Directory.Folder
        for asset in assets when _.startsWith asset.name, item.name
          @_deleteAsset asset

      else
        asset = _.find assets, (asset) => asset.name is item.name
        @_deleteAsset asset

  _deleteAsset: (asset) ->
    # Put the asset in trash.
    LOI.Assets.Asset.update asset.constructor.className, asset._id,
      $set: name: "trash/#{asset.name}"
