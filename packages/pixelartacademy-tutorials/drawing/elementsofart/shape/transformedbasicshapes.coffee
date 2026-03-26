LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.TransformedBasicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @displayName: -> "Transformed basic shapes"
  
  @description: -> """
    Basic shapes will not always appear in their default orientation.
  """
  
  @fixedDimensions: -> width: 100, height: 60
  
  @initialize()
  
  Asset = @
  
  class @Default extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Default"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Only some of the objects will fit into exact squares and circles.
    """
    
    @initialize()
  
  class @Scaled extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Scaled"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      You might have to resize shapes horizontally or vertically and use rectangles and ellipses.
    """
    
    @initialize()
  
  class @Rotated extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Rotated"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    
    @message: -> """
      Sometimes you will even need to rotate shapes.
      The rectangle and ellipse tools won't help much here, so you'll have to use lines and manually pixel the curves.
    """
    
    @initialize()
  
  class @Skewed extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Skewed"
    @assetClass: -> Asset
    
    @stepNumber: -> 4
    
    @message: -> """
      Finally, the shapes can be skewed in various ways, often to achieve the effect of perspective.
    """
    
    @initialize()
