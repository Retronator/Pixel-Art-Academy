AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.CameraAngle.SelectSpriteDialog extends LOI.Assets.Editor.AssetOpenDialog
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.CameraAngle.SelectSpriteDialog'
  @register @id()

  _fileManagerOptions: ->
    documents: LOI.Assets.Sprite.documents
    defaultOperation: => @_open()
    multipleSelect: false

  _subscribeToDocuments: ->
    LOI.Assets.Asset.all.subscribe @, LOI.Assets.Sprite.className

  _open: ->
    return unless selectedItem = @fileManager.selectedItems()[0]
    
    # Find the editor view in the interface.
    cameraAngleViews = @interface.allChildComponentsOfType LOI.Assets.MeshEditor.CameraAngle

    unless cameraAngleViews.length
      throw new AE.InvalidOperationException "There is no CameraAngle view in the interface."
      
    # TODO: Find a way to figure out which view requested the dialog. For now we just take the first.
    targetCameraAngleView = cameraAngleViews[0]
    targetCameraAngleView.setSprite selectedItem._id
    
    @closeDialog()
