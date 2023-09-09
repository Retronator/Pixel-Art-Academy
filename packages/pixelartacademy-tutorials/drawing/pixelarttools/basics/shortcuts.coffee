LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Shortcuts extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Shortcuts'

  @displayName: -> "Shortcuts"

  @description: -> """
      An efficient pixel artist will learn shortcuts to switch between tools.

      - B: pencil (brush)
      - E: eraser
      - G: color fill (gradient)
    """

  @fixedDimensions: -> width: 12, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmapString: -> """
      |
      |
      |  00000000
      | 0        0
      |0          0
      |000000000000
    """

  @goalBitmapString: -> """
      |  0      0
      |   0    0
      |  00000000
      | 00 0000 00
      |000000000000
      |0 00000000 0
      |0 0      0 0
      |   00  00
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  editorStyleClasses: -> 'hidden-tools'

  @initialize()

  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      - B: pencil
      - E: eraser
      - G: color fill
    """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
    
      # Show until the asset is completed.
      not asset.completed()
  
    @activeDisplayState: ->
      # Show this tip closed.
      PAA.PixelPad.Systems.Instructions.DisplayState.Closed
      
    @delayDuration: -> 3
  
    @resetDelayOnOperationExecuted: -> true
    
    @initialize()
    
    onOperationExecuted: (document, operation, changedFields) ->
      return unless document._id is @bitmapId
      
      # Don't reset the delay anymore once it has ran out so that when shortcuts are shown they don't disappear anymore.
      return unless @delayed()
      
      @resetDelay()
