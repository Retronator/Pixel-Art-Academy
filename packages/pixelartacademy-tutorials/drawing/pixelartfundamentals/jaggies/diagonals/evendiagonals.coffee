LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals"

  @displayName: -> "Even diagonals"
  
  @description: -> """
    Not all jaggies are created equal and not all diagonals have the same aesthetic.
  """
  
  @fixedDimensions: -> width: 26, height: 26
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/evendiagonals-#{step}.png" for step in [1..4]
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    markup: ->
      # Write diagonal ratios next to lines.
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        lineEvaluation = linePart.evaluate()
        markup.push Markup.PixelArt.diagonalRatioText linePart unless lineEvaluation.type is StraightLine.Type.AxisAligned
        
      markup
  
  class @StepInstructionWithSegmentLines extends @StepInstruction
    markup: ->
      markup = super arguments...
      
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      # Add perceived lines for straight lines.
      for line in pixelArtEvaluation.layers[0].lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        markup.push Markup.PixelArt.perceivedStraightLine linePart

      markup
      
  class @Horizontal extends @StepInstruction
    @id: -> "#{Asset.id()}.Aligned"
    @stepNumber: -> 1
    
    @message: -> """
      Vertical and horizontal lines in pixel art don't create jaggies. Certain angles (such as 0° and 90°) are thus more commonly used than others.
    """
    
    @initialize()
  
  class @OneToOne extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToOne"
    @stepNumber: -> 2
    
    @message: -> """
      Even though a 45° diagonal creates jaggies, the line follows a uniform pattern by raising exactly one pixel for each pixel traveled forward. We call this the 1:1 diagonal.
    """
    
    @initialize()
  
  class @OneToTwo extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 3
    
    @message: -> """
      If the segments are 2 pixels long, we get the 1:2 and 2:1 diagonals.
    """
    
    @initialize()
  
  class @Even extends @StepInstructionWithSegmentLines
    @id: -> "#{Asset.id()}.Even"
    @stepNumber: -> 4
    
    @message: -> """
      Whenever we use the same number of pixels in each segment, we create even or 'perfect' diagonals.
      These angles are considered perfect in pixel art because the corners of the segments exactly follow the perceived lines.
    """
    
    @activeConditions: ->
      # Show with the correct step.
      return unless @activeStepNumber() in @stepNumbers()
      
      # Note: We want this instruction to appear also when the asset
      # is completed, which is why we're overriding this method.
      
    @initialize()
