AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.FileManager.Directory.NewFolder extends FM.Action
  @id: -> 'LOI.Assets.Components.FileManager.Directory.NewFolder'
  @displayName: -> "New folder"

  @initialize()
    
  execute: (dropdown) ->
    directory = dropdown.data().value().directory
    directory.newFolder()
