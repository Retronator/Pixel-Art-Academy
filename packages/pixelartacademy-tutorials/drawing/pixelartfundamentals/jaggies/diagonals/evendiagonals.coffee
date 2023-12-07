LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtGrading.Line.Part.StraightLine
Markup = PAA.Tutorials.Drawing.PixelArtFundamentals.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EvenDiagonals"

  @displayName: -> "Even diagonals"
  
  @description: -> """
    Not all jaggies are created equal and not all diagonals have the same aesthetic.
  """
  
  @fixedDimensions: -> width: 26, height: 26
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/evendiagonals-#{step}.png" for step in [1..4]
  
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
      
      for line in pixelArtGrading.lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtGrading.Line.Part.StraightLine
        
        lineGrading = linePart.grade()
        markup.push Markup.diagonalRatioText linePart, lineGrading unless lineGrading.type is StraightLine.Type.AxisAligned
        
      markup
  
  class @InstructionStepWithSegmentLines extends @InstructionStep
    markup: ->
      markup = super arguments...
      
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtGrading = asset.pixelArtGrading()
      
      # Add intended lines for straight lines.
      for line in pixelArtGrading.lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtGrading.Line.Part.StraightLine
        
        markup.push Markup.intendedLine linePart

      markup
      
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
      Even though a 45° diagonal creates jaggies, the line follows a uniform pattern by raising exactly one pixel for each pixel traveled forward. We call this the 1:1 diagonal.
    """
    
    @initialize()
  
  class @OneToTwo extends @InstructionStep
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 3
    
    @message: -> """
      If the segments are 2 pixels long, we get the 1:2 and 2:1 diagonals.
    """
    
    @initialize()
  
  class @Even extends @InstructionStepWithSegmentLines
    @id: -> "#{Asset.id()}.Even"
    @stepNumber: -> 4
    
    @message: -> """
      Whenever we use the same number of pixels in each segment, we create even or 'perfect' diagonals.
      These angles are considered perfect in pixel art because the corners of the segments exactly follow the intended line.
    """
    
    @initialize()
