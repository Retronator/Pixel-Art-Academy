LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Outlines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "Outlines"
  
  @description: -> """
    If you join lines together, you can draw outlines of objects.
  """
  
  @fixedDimensions: -> width: 25, height: 25

  @referenceNames: -> [
    'outlines-banana'
    'outlines-orange'
    'outlines-apple'
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
