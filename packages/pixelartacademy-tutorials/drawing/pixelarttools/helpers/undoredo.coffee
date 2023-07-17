LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.UndoRedo extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.UndoRedo'

  @displayName: -> "Undo/redo"

  @description: -> """
      One of the biggest advantages of digital art is the ability to undo our actions.
      
      Shortcuts:

      - Cmd/ctrl + Z: undo
      - Cmd/ctrl + shift + Z: redo
    """

  @fixedDimensions: -> width: 59, height: 59
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
  @maxClipboardScale: -> 1

  @imageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/codemasters.png"

  @goalImageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/codemasters-goal.png"

  @bitmapInfo: -> "CodeMasters logo from the loading screen of Fast Food (ZX Spectrum), 1989"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
    PAA.Practice.Software.Tools.ToolKeys.Undo
    PAA.Practice.Software.Tools.ToolKeys.Redo
  ]

  minClipboardScale: -> 1
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Complete the dithering pattern on the CodeMasters logo.
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      Whoops! Use the undo button under the pencil to get back on track.
      
      Shortcuts:
      - Cmd/ctrl + Z: undo
      - Cmd/ctrl + shift + Z: redo
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      @assetHasExtraPixels asset
    
    @priority: -> 1
    
    @initialize()
