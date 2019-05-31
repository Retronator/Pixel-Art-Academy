AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.NewFolder extends FM.Action
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.NewFolder'
  @displayName: -> "New folder"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    directory.newFolder()
