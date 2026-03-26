LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Line.CurvedLines extends PAA.Tutorials.Drawing.ElementsOfArt.Line.Asset
  @displayName: -> "Curved lines"
  
  @description: -> """
    Curves are trickier and require more practice but with pixel art, it's always easy to fix them.
  """
  
  @fixedDimensions: -> width: 38, height: 35
  
  @initialize()
  
  Asset = @
  
  class @FirstWay extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.FirstWay"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      There are multiple ways to draw a curve with the pencil. The hardest but most natural is:
      1. Click and drag along the line to complete it in one stroke.
    """
    
    @initialize()
  
  class @SecondWay extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.SecondWay"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      Don't worry if the line looks wobbly or uneven, you will learn how to clean it up in the future. For now, try a method that will ensure 1-pixel width:
      2. Click on the starting pixel. Press and hold shift. Click along the line in small increments to draw a curve out of many straight segments.
    """
    
    @initialize()
  
  class @ThirdWay extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.ThirdWay"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      The final technique is the slowest but offers the most control:
      3. Zoom in and click on the pixels that the line most clearly crosses.
    """
    
    @initialize()
  
  class @AnyWay extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.AnyWay"
    @assetClass: -> Asset
    @stepNumber: -> 4
    
    @message: -> """
      Complete the final curve in whatever way you prefer.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the asset is completed.
      return if asset.completed()
      
      super arguments...
      
    @initialize()
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
        You did it!
        
        And don't worry if you're not happy with the look yet. You will learn the rules behind pixel art curves soon.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
