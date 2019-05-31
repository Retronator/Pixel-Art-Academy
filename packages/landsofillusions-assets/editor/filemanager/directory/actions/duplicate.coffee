AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.Duplicate extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.Duplicate'
  @displayName: -> "Duplicate"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory

    for item in directory.selectedItems()
      if item instanceof LOI.Assets.Editor.FileManager.Directory.Folder
        # Duplicate all files with the folder prefix.
        prefix = item.name
        dotIndex = prefix.lastIndexOf '.'

        if dotIndex > -1
          dotExtension = prefix.substring dotIndex
          folderName = prefix.substring 0, dotIndex
          newPrefix = "#{folderName} copy#{dotExtension}"

        else
          newPrefix = "#{prefix} copy"

        for asset in directory.documents() when _.startsWith asset.name, prefix
          newName = "#{newPrefix}#{asset.name.substring prefix.length}"
          @_duplicate asset, newName

      else
        # Duplicate the asset itself.
        newName = "#{item.name} copy"
        @_duplicate item, newName

  _duplicate: (asset, name) ->
    LOI.Assets.Asset.duplicate asset.constructor.className, asset._id, (error, duplicateAssetId) =>
      if error
        console.error error
        return

      # Rename the duplicate.
      LOI.Assets.Asset.update asset.constructor.className, duplicateAssetId,
        $set: {name}
