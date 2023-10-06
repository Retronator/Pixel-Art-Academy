LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines extends PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines'

  @displayName: -> "Broken lines"

  @description: -> """
      Lines often change direction. You've been practicing drawing them your whole life when writing.
    """

  @fixedDimensions: -> width: 54, height: 21
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/elementsofart/line/brokenlines.svg"

  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
    ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Combine your skill of drawing straight and curved lines to draw all the numbers.
    """
    
    @initialize()
