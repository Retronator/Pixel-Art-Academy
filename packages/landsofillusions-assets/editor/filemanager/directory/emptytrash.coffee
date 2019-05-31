AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.EmptyTrash extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.EmptyTrash'
  @displayName: -> "Empty trash"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    assetsToBeRemoved = _.filter directory.documents(), (asset) -> _.startsWith asset.name, 'trash/'

    @interface.displayDialog
      contentComponentId: LOI.Assets.Editor.Dialog.id()
      contentComponentData:
        title: "Empty trash"
        message: "Do you want to permanently delete #{assetsToBeRemoved.length} assets?"
        buttons: [
          text: "Delete"
          value: true
        ,
          text: "Cancel"
        ]
        callback: (shouldDelete) =>
          return unless shouldDelete

          for asset in assetsToBeRemoved
            LOI.Assets.Asset.remove asset.constructor.className, asset._id
