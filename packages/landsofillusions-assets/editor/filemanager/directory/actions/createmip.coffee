AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.CreateMip extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.CreateMip'
  @displayName: -> "Create Mip"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    selectedItems = directory.selectedItems()

    if selectedItems.length is 1 and selectedItems[0] instanceof LOI.Assets.Editor.FileManager.Directory.Folder
      # Convert files in an existing folder to mipmaps.
      folder = selectedItems[0]

      escapedPath = folder.name.replace /\//g, '\/'

      sprites = LOI.Assets.Sprite.documents.fetch
        name: ///^#{escapedPath}///

      mipFolderPath = "#{folder.name}.mip"

    else
      mipFolderPath = null
      sprites = []

      for item in selectedItems when not (item instanceof LOI.Assets.Editor.FileManager.Directory.Folder)
        sprites.push item

        if mipFolderPath
          # Find common prefix.
          for character, index in mipFolderPath
            continue if item.name[index] is character

            mipFolderPath = mipFolderPath.substring 0, index
            break

        else
          mipFolderPath = item.name

      mipFolderPath = "#{_.trim mipFolderPath}.mip"

    for sprite in sprites
      # Ask for sprite bounds.
      LOI.Assets.Asset.getData LOI.Assets.Sprite.className, sprite._id, {bounds: 1}, (error, sprite) =>
        if error
          console.error error
          return

        # The filename for mip sprites is the width of the sprite.
        fileName = sprite.bounds.width

        LOI.Assets.Asset.update 'Sprite', sprite._id,
          $set:
            name: "#{mipFolderPath}/#{fileName}"
