LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Tutorials.Drawing.MarkupEngineComponent.TextOriginPosition

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals"

  @displayName: -> "Even diagonals"
  
  @description: -> """
    Not all jaggies are created equal and not all diagonals have the same aesthetic.
  """
  
  @fixedDimensions: -> width: 28, height: 32
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/evendiagonals-#{step}.png" for step in [1..5]
  
  @markup: -> true
  @pixelArtGrading: -> true
  
  @initialize()
  
  Asset = @
  
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      asset.stepAreas()[0].activeStepIndex() is @stepNumber() - 1
    
    @resetDelayOnOperationExecuted: -> true
    
    markup: ->
      # Write diagonal ratios next to lines.
      return unless asset = @getActiveAsset()
      return unless pixelArtGrading = asset.pixelArtGrading()
      
      markup = []
      
      textBase = Asset.markupTextBase()
      
      for line in pixelArtGrading.lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtGrading.Line.Part.StraightLine
        
        if diagonalRatio = linePart.diagonalRatio()
          startPoint = _.first linePart.points
          endPoint = _.last linePart.points
          rightPoint = if endPoint.x > startPoint.x then endPoint else startPoint
  
          markup.push
            text: _.extend {}, textBase,
              position:
                x: rightPoint.x + 1.75, y: rightPoint.y - 0.75, origin: TextOriginPosition.BottomLeft
              value: "#{diagonalRatio.numerator}:#{diagonalRatio.denominator}"
        
      markup
    
  class @instructionStepWithSegmentLines extends @InstructionStep
    markup: ->
      palette = LOI.palette()
      
      return unless asset = @getActiveAsset()
      return unless pixelArtGrading = asset.pixelArtGrading()
    
  class @Horizontal extends @InstructionStep
    @id: -> "#{Asset.id()}.Aligned"
    @stepNumber: -> 1
    
    @message: -> """
      Vertical and horizontal lines in pixel art don't create jaggies. Certain angles (such as 0° and 90°) are thus more commonly used than others.
    """
    
    @initialize()
  
  class @OneToOne extends @InstructionStep
    @id: -> "#{Asset.id()}.OneToOne"
    @stepNumber: -> 2
    
    @message: -> """
      Even though a 45° diagonal creates jaggies, they follow a uniform pattern by raising exactly one pixel for each pixel traveled forward. We call this the 1:1 diagonal.
    """
    
    @initialize()
  
  class @OneToTwo extends @InstructionStep
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 3
    
    @message: -> """
      If the segments are 2 pixels long, we get the 1:2 diagonal.
    """
    
    @initialize()
  
  class @Even extends @InstructionStep
    @id: -> "#{Asset.id()}.Even"
    @stepNumber: -> 4
    
    @message: -> """
      Whenever we use an even number of pixels in each segment we create even or 'perfect' diagonals.
      These angles are considered perfect in pixel art because the corners of the segments exactly follow the intended line.
    """
    
    @initialize()
  
  class @Intermediary extends @InstructionStep
    @id: -> "#{Asset.id()}.Intermediary"
    @stepNumber: -> 5
    
    @message: -> """
      The lines that fall between the even diagonals are called intermediary diagonals.
      Their segments change in length and lead to jaggies that don't align perfectly with the diagonal.
    """
    
    @initialize()
