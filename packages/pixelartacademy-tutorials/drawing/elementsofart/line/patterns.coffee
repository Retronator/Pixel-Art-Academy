LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.Patters extends PAA.Tutorials.Drawing.ElementsOfArt.Line.AssetWithReferences
  @displayName: -> "EdgPatterses"
  
  @description: -> """
    We can arrange lines into patterns to indicate details, texture, or shading.
  """
  
  @fixedDimensions: -> width: 29, height: 39

  @referenceNames: -> [
    'patterns-bamboo'
    'patterns-sunset'
  ]
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the object in detail by combining straight, curved, and broken lines.
    """
    
    @initialize()
