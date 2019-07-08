AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.SpriteSelectDialog extends LOI.Assets.Editor.AssetOpenDialog
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.SpriteSelectDialog'
  @register @id()
  
  template: -> @constructor.id()

  _fileManagerOptions: ->
    documents: LOI.Assets.Sprite.documents
    defaultOperation: => @_open()
    multipleSelect: false

  _subscribeToDocuments: ->
    LOI.Assets.VisualAsset.allSystem.subscribe @, LOI.Assets.Sprite.className

  _open: (selectedItem) ->
    selectedItem ?= @fileManager.selectedItems()[0]
    return unless selectedItem

    # Return the selected item to the caller.
    dialogData = @data()
    dialogData.open selectedItem
    
    @closeDialog()

  events: ->
    super(arguments...).concat
      'click .new-button': @onClickNewButton

  onClickNewButton: (event) ->
    LOI.Assets.Asset.insert LOI.Assets.Sprite.className, (error, assetId) =>
      if error
        console.error error
        return

      # TODO: Put the sprite in the same folder as the mesh.

      # Select the new asset.
      @_open _id: assetId
