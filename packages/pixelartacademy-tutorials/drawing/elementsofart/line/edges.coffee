LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Edges extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "Edges"
  
  @description: -> """
    Lines are also used to draw the internal edges of objects.
  """
  
  @fixedDimensions: -> width: 29, height: 39

  @referenceNames: -> [
    'edges-cube'
    'edges-pottedplant'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the object by combining straight, curved, and broken lines.
    """
    
    @initialize()
