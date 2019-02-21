AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CameraAngle.SelectSpriteDialog extends LOI.Assets.Editor.AssetOpenDialog
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.CameraAngle.SelectSpriteDialog'
  @register @id()
  
  template: -> @constructor.id()

  _fileManagerOptions: ->
    documents: LOI.Assets.Sprite.documents
    defaultOperation: => @_open()
    multipleSelect: false

  _subscribeToDocuments: ->
    LOI.Assets.Asset.all.subscribe @, LOI.Assets.Sprite.className

  _open: (selectedItem) ->
    selectedItem ?= @fileManager.selectedItems()[0]
    return unless selectedItem

    # Find the editor view in the interface.
    cameraAngleViews = @interface.allChildComponentsOfType LOI.Assets.MeshEditor.CameraAngle

    unless cameraAngleViews.length
      throw new AE.InvalidOperationException "There is no CameraAngle view in the interface."
      
    # TODO: Find a way to figure out which view requested the dialog. For now we just take the first.
    targetCameraAngleView = cameraAngleViews[0]
    targetCameraAngleView.setSprite selectedItem._id
    
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
