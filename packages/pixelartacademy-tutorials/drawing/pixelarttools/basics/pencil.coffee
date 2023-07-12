LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Pencil extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Pencil'

  @displayName: -> "Pencil"

  @description: -> """
      Learn how to use the most essential pixel art tool: a 1-pixel pencil.
    """

  @fixedDimensions: -> width: 8, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @goalBitmapString: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      | 0 00 0
      |0      0
      | 0    0
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    @unlockEraser = new ReactiveField false

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser if @unlockEraser()
  ]
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Pencil.Instruction'
  
    @message: -> """
      Use the pencil to fill the pixels with the dot in the middle.
    """

    @activeConditions: ->
      return unless asset = @getActiveAssetOfType Asset
      
      # Show until the asset is completed.
      not asset.completed()
      
    @delayDuration: -> 10
    
    @initialize()
  
    onActivate: ->
      super arguments...
    
      # Start listening to actions done on the asset.
      @bitmapId = @constructor.getActiveAssetOfType(Asset).bitmapId()
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, @onOperationExecuted
      
    onDeactivate: ->
      super arguments...

      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandlers @
  
    onOperationExecuted: (document, operation, changedFields) ->
      return unless document._id is @bitmapId
      
      @resetDelay()
    
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Pencil.Error'
    
    @message: -> """
      Whoops, you went too far! Use the eraser to delete unwanted pixels.
    """

    @activeConditions: ->
      return unless asset = @getActiveAssetOfType Asset
      
      # Show when there are any extra pixels present.
      @assetHasExtraPixels asset

    @priority: -> 1
    
    @initialize()
  
    onDisplay: ->
      # Unlock the eraser.
      asset = @constructor.getActiveAssetOfType Asset
      asset.unlockEraser true
