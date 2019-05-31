AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.CreateRot8 extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.CreateRot8'
  @displayName: -> "Create Rot8"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    selectedItems = directory.selectedItems()

    fileNames = (_.kebabCase value for key, value of LOI.Engine.RenderingSides.Keys)

    # We need the filenames go from long to short since short ones
    # are subsets of long ones and we don't want them to match first.
    fileNames = _.reverse _.sortBy fileNames, (fileName) => fileName.length

    if selectedItems.length is 1 and selectedItems[0] instanceof LOI.Assets.Editor.FileManager.Directory.Folder
      # Convert files in an existing folder to rot8.
      folder = selectedItems[0]

      escapedPath = folder.name.replace /\//g, '\/'

      sprites = LOI.Assets.Sprite.documents.fetch
        name: ///^#{escapedPath}///

      rot8FolderPath = "#{folder.name}.rot8"

    else
      rot8FolderPath = null
      sprites = []

      for item in selectedItems when not (item instanceof LOI.Assets.Editor.FileManager.Directory.Folder)
        sprites.push item

        # Find the common part of the item name (without the direction suffix).
        if fileName = _.find(fileNames, (fileName) => _.endsWith item.name, fileName)
          commonItemName = item.name.substring 0, item.name.length - fileName.length

        else
          commonItemName = item.name

        if rot8FolderPath
          # Find common prefix.
          for character, index in rot8FolderPath
            continue if commonItemName[index] is character

            rot8FolderPath = rot8FolderPath.substring 0, index
            break

        else
          rot8FolderPath = item.name

      rot8FolderPath = "#{_.trim rot8FolderPath}.rot8"

    for sprite in sprites
      fileName = _.find fileNames, (fileName) => _.endsWith sprite.name, fileName
      fileName ?= sprite.name.substring sprite.name.lastIndexOf('/') + 1

      LOI.Assets.Asset.update 'Sprite', sprite._id,
        $set:
          name: "#{rot8FolderPath}/#{fileName}"
