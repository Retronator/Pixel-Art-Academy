LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Outlines2 extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "Outlines 2"
  
  @description: -> """
    Some objects can be drawn in a more stylized way.
  """
  
  @fixedDimensions: -> width: 29, height: 39

  @referenceNames: -> [
    'outlines-palmtree'
    'outlines-sprucetree'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the object's outline by combining straight, curved, and broken lines.
    """
    
    @initialize()
