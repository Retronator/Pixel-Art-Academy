LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Jaggies extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @displayName: -> "Jaggies"
  
  @description: -> """
    Learn about the main stylistic characteristic of pixel art.
  """
  
  @fixedDimensions: -> width: 45, height: 25
  
  @initialize()
  
  Asset = @
  
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      return unless asset.currentActivePathIndex() is @stepNumber() - 1
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
  class @Aligned extends @InstructionStep
    @id: -> "#{Asset.id()}.Aligned"
    @stepNumber: -> 1
    
    @message: -> """
      Pixel art is drawn on a raster grid. When drawing lines and edges that align with the grid, the result perfectly matches the intended shapes.
    """
    
    @initialize()
  
  class @NonAligned extends @InstructionStep
    @id: -> "#{Asset.id()}.NonAligned"
    @stepNumber: -> 2
    
    @message: -> """
      When lines don't align with the grid, such as with diagonals and curves, the raster nature of the medium becomes apparent.
    """
    
    @initialize()
  
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      The lines that should have been straight or smooth become jagged—spiky and rough.
      These stair-like deformations of the intended shapes are called 'jaggies' and contribute to the blocky appearance of pixel art.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
