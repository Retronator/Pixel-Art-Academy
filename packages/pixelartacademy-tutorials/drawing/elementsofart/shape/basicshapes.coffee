LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.BasicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @displayName: -> "Basic shapes"
  
  @description: -> """
    Combine lines to construct essential shapes.
  """
  
  @fixedDimensions: -> width: 109, height: 46
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw lines to create the 3 most basic shapes: a square, a triangle, and a circle.
    """
    
    @initialize()
