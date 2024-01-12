LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Broken lines"

  @description: -> """
    Lines often change direction in corners to create more complex designs.
  """

  @fixedDimensions: -> width: 65, height: 27
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Chain together straight and curved lines from corner to corner.
    """
    
    @initialize()
