AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.SoundSelectDialog extends LOI.Assets.Editor.AssetOpenDialog
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.SoundSelectDialog'
  @register @id()
  
  onRendered: ->
    super arguments...

    dialogData = @data()
    @fileManager.selectItem dialogData.selectItem if dialogData.selectItem

  template: -> @constructor.id()

  _fileManagerOptions: ->
    documents: LOI.Assets.AudioEditor.PublicDirectory.soundFiles
    defaultOperation: => @_open()
    multipleSelect: false

  _subscribeToDocuments: ->
    LOI.Assets.AudioEditor.PublicDirectory.allSoundFiles.subscribe @

  _open: (selectedItem) ->
    selectedItem ?= @fileManager.selectedItems()[0]
    return unless selectedItem

    # Return the selected item to the caller.
    dialogData = @data()
    dialogData.open selectedItem
    
    @closeDialog()
