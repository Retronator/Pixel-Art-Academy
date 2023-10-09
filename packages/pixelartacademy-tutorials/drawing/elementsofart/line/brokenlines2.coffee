LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.BrokenLines2 extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Broken lines 2"

  @description: -> """
    Even if you didn't realize it, you've been practicing drawing broken lines all your life when writing.
  """

  @fixedDimensions: -> width: 54, height: 21
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Combine your skill of drawing straight and curved lines to draw all the numbers.
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      You went too far from the line, but don't worry. You can easily fix it with the eraser.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      asset.hasExtraPixels()
    
    @priority: -> 1
    
    @initialize()
