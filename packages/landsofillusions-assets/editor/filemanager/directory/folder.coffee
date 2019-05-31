AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Directory.Folder
  @id: -> 'LOI.Assets.Editor.FileManager.Directory.NewFolder'
    
  constructor: (@name, @sortingName) ->

  iconName: ->
    return 'rot8' if _.endsWith @name, '.rot8'
    return 'trash' if @name is 'trash'

    'folder'
