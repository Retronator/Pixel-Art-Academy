AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.FlipHorizontal extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.FlipHorizontal'
  @displayName: -> "Flip horizontal"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    assets = directory.documents()

    for item in directory.selectedItems()
      if item instanceof LOI.Assets.Editor.FileManager.Directory.Folder
        for asset in assets when _.startsWith asset.name, item.name
          @_flipAsset asset

      else
        asset = _.find assets, (asset) => asset.name is item.name
        @_flipAsset asset

  _flipAsset: (asset) ->
    return unless asset instanceof LOI.Assets.Sprite

    # Flip the sprite. Note that the simulation will report errors since no pixels
    # are present on the client for file manager sprites. This is expected behavior.
    LOI.Assets.Sprite.flipHorizontal asset._id, 0

    # See if we should rename the file.
    if _.endsWith asset.name, 'left'
      newName = "#{asset.name.substring 0, asset.name.length - 4}right"

    else if _.endsWith asset.name, 'right'
      newName = "#{asset.name.substring 0, asset.name.length - 5}left"

    return unless newName

    LOI.Assets.Asset.update asset.constructor.className, asset._id,
      $set: name: newName
