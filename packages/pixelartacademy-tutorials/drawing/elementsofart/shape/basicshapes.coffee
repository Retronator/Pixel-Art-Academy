LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.BasicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.Asset
  @displayName: -> "Basic shapes"
  
  @description: -> """
    To start learning how to draw, you only need to be able to draw 3 basic shapes.
  """
  
  @fixedDimensions: -> width: 109, height: 46
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Use the ruler or pencil to draw the 3 most basic shapes: a square, a triangle, and a circle.
    """
    
    @initialize()
