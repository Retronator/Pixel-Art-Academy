LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Line.#{_.pascalCase @displayName()}"
  
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/elementsofart/line/#{_.fileCase @displayName()}.svg"

  @breakPathsIntoSteps: -> true
  
  @minClipboardScale: -> 2
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
    ]
