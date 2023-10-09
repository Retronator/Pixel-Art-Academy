LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.StraightLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Straight lines"
  
  @description: -> """
    The most straightforward lines! If you know your tools well, drawing them should be as easy as shift-clicking.
  """
  
  @fixedDimensions: -> width: 28, height: 28
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the line by using the pencil. You can either:

      - Click on individual pixels that the line crosses.
      - Click and drag along the line to complete it in one stroke.
      - Click on the starting pixel and then shift-click on the ending pixel.
    """
    
    @initialize()
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      You went outside the line, but don't worry. You can easily fix it with the eraser.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      asset.hasExtraPixels()
    
    @priority: -> 1
    
    @initialize()
