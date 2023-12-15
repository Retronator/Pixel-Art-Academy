AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Instructions.Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
  # The default amount of time before we show instructions to the user to let them figure it out themselves.
  @defaultDelayDuration = 10
  
  @assetClass: -> throw new AE.NotImplementedException "You must specify the asset class this instruction is for."
  
  @getEditor: -> PAA.PixelPad.Apps.Drawing.Editor.getEditor()
  
  @getActiveAsset: ->
    # We must be in the editor on the provided asset.
    return unless editor = @getEditor()
    return unless editor.drawingActive()
    
    return unless asset = editor.activeAsset()
    return unless asset instanceof @assetClass()
    
    asset
  
  @resetDelayOnOperationExecuted: -> false
  
  getEditor: -> @constructor.getEditor()
  getActiveAsset: -> @constructor.getActiveAsset()

  onActivate: ->
    super arguments...
  
    if @constructor.resetDelayOnOperationExecuted()
      # Start listening to actions done on the asset.
      @bitmapId = @constructor.getActiveAsset().bitmapId()
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, @onOperationExecuted

  onDeactivate: ->
    super arguments...
  
    if @constructor.resetDelayOnOperationExecuted()
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandlers @

  onOperationExecuted: (document, operation, changedFields) ->
    return unless document._id is @bitmapId
  
    @resetDelay()
