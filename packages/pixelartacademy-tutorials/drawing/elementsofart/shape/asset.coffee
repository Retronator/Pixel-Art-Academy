LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.ElementsOfArt.Shape.#{_.pascalCase @displayName()}"
  
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{_.fileCase @displayName()}.svg"
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.Line
      PAA.Practice.Software.Tools.ToolKeys.Rectangle
      PAA.Practice.Software.Tools.ToolKeys.Ellipse
    ]

  # Note: We have to override initializeStepsInAreaWithResources instead of initializeSteps since
  # this will be called when creating steps after reference selection.
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create a path step that has increased tolerance to allow for more freedom where you place the lines.
    svgPaths = stepResources.svgPaths.svgPaths()
    
    for svgPath, index in svgPaths
      new @constructor.PathStep @, stepArea,
        startPixels: if index is 0 then @resources.startPixels else null
        svgPaths: [svgPath]
        tolerance: 0
