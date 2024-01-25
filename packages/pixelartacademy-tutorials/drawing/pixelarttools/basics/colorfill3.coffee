AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill3 extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill3'

  @displayName: -> "Color fill 3"

  @description: -> """
      When using the color fill, you have to watch out for gaps in the outlines.
    """

  @fixedDimensions: -> width: 24, height: 18
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |
      |     00000000000000
      |    0              0
      |   0                0
      |  0                  0
      | 0                    0
      | 0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0      00 0000       0
      | 0     0       0      0
      | 0    0         0     0
      | 0   0           0    0
      | 00000           000000
    """

  @goalBitmapString: -> """
      |
      |     00000000000000
      |    0000000000000000
      |   000000000000000000
      |  00000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000       00000000
      | 000000         0000000
      | 00000           000000
      | 00000           000000
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"
  
  
  constructor: ->
    super arguments...
    
    @unlockUndo = new ReactiveField false
    
  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Undo if @unlockUndo()
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Use the pencil to close the holes in the outline before using the color fill.
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @priority: -> 1
    
    @toolId: -> throw new AE.NotImplementedException "You must provide which tool was required to produce this error."

    @activeConditions: ->
      return unless asset = @getActiveAsset()
  
      # Show when there are any extra pixels present and the last operation was a color fill.
      return unless asset.hasExtraPixels()
  
      bitmap = asset.bitmap()
      lastAction = bitmap.partialAction or bitmap.history[bitmap.historyPosition - 1]
      lastAction.operatorId is @toolId()

    onDisplayed: ->
      # Unlock the undo.
      asset = @constructor.getActiveAsset()
      asset.unlockUndo true
      
  class @ColorFillError extends @Error
    @id: -> "#{Asset.id()}.ColorFillError"
    @assetClass: -> Asset
    
    @message: -> """
      Whoops, the color spilled outside the sprite! Use the undo button on the left to get back on track.
    """
    
    @toolId: -> LOI.Assets.SpriteEditor.Tools.ColorFill.id()

    @initialize()
    
  class @PencilError extends @Error
    @id: -> "#{Asset.id()}.PencilError"
    @assetClass: -> Asset
    
    @message: -> """
      You've drawn a bit too much! Use the undo button on the left to get back on track.
    """
    
    @toolId: -> LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @initialize()
