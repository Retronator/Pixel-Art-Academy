LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.BasicShapesBreakdown extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences
  @displayName: -> "Basic shapes breakdown"
  
  @description: -> """
    When drawing a scene, you can start by simplifying its objects to their basic shapes.
  """
  
  @fixedDimensions: -> width: 160, height: 70
  
  @referenceNames: -> [
    'basicshapesbreakdown-island'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the indicated shapes to construct the scene from the reference.
    """
    
    @initialize()
