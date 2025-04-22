LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Shape.#{_.pascalCase @displayName()}"
  
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{_.fileCase @displayName()}.svg"

  @breakPathsIntoSteps: -> true
  
  @minClipboardScale: -> 1
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
    ]
