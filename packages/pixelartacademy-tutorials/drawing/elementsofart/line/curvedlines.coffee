LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.CurvedLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Curved lines"
  
  @description: -> """
    Curves require a steadier hand and more practice but with pixel art, it's always easy to fix them.
  """
  
  @fixedDimensions: -> width: 38, height: 35
  
  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the line by using the pencil. You can either:

      - Click on individual pixels that the line crosses.
      - Click and drag along the line to complete it in one stroke.
      - Click on the starting pixel and then shift-click along the line in small increments to draw a curve out of many straight segments.
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
