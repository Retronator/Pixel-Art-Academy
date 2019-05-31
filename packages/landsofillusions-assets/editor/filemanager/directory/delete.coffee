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
      for asset in assets when _.startsWith asset.name, item.name
        # Put the asset in trash.
        LOI.Assets.Asset.update asset.constructor.className, asset._id,
          $set: name: "trash/#{asset.name}"
