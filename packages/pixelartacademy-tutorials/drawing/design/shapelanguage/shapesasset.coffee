LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.Design.ShapeLanguage.ShapesAsset extends PAA.Tutorials.Drawing.Design.ShapeLanguage.Asset
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/design/shapelanguage/#{_.fileCase @displayName()}.svg"
  
  @breakPathsIntoSteps: -> true
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.Line
      PAA.Practice.Software.Tools.ToolKeys.Rectangle
      PAA.Practice.Software.Tools.ToolKeys.Ellipse
    ]
