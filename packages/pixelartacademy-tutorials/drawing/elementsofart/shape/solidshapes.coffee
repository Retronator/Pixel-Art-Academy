LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.SolidShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @displayName: -> "Solid shapes"
  
  @description: -> """
    Shapes can be filled with color.
  """
  
  @fixedDimensions: -> width: 87, height: 42
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
  @backgroundColor: ->
    paletteColor:
      ramp: 13
      shade: 0
    
  @initialize()
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
    ]
    
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    svgPaths = Array.from stepResources.svgPaths.svgPaths()
    pathsPerSteps = [1, 1, 1, 3, 8]
    hintStrokeWidths = [1, 1, 1, 1, 5]

    startIndex = 0
    
    for pathsPerStep, stepIndex in pathsPerSteps
      pathStep = new PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PathStep @, stepArea,
        svgPaths: svgPaths[startIndex...(startIndex + pathsPerStep)]
        hintStrokeWidth: hintStrokeWidths[stepIndex]
      
      startIndex += pathsPerStep
      pathStep
      
  Asset = @
  
  class @Lines extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Lines"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Lines create shapes by enclosing a space.
    """
    
    @initialize()
  
  class @Fill extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Fill"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      A shape can be made solid by filling in the enclosed space.
    """
    
    @initialize()
  
  class @Combine extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Combine"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Solid shapes can be combined to create complex shapes.
    """
    
    @initialize()
  
  class @Colors extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Colors"
    @assetClass: -> Asset
    
    @stepNumber: -> 4
    
    @message: -> """
      By using multiple colors, we can create shapes for each part of an object.
    """
    
    @initialize()

  class @LineColors extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.LineColors"
    @assetClass: -> Asset
    
    @stepNumber: -> 5
    
    @message: -> """
      Outlines can also use different colors.
    """
    
    @initialize()
