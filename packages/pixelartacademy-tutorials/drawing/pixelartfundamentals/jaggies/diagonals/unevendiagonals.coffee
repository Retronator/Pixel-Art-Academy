LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtGrading.Line.Part.StraightLine
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonals extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonals"

  @displayName: -> "Uneven diagonals"
  
  @description: -> """
    To get to all possible angles, we need diagonals with uneven segment lengths.
  """
  
  @fixedDimensions: -> width: 39, height: 36
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/unevendiagonals-#{step}.png" for step in [1..4]
  
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
      return unless asset.stepAreas()[0].activeStepIndex() is @stepNumber() - 1
      
      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtGrading = asset.pixelArtGrading()
      
      markup = []
      
      for line in pixelArtGrading.lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtGrading.Line.Part.StraightLine
        
        # Add intended line.
        markup.push Markup.PixelArt.intendedLine linePart
        
      markup
  
  class @InstructionStepWithDiagonalRatios extends @InstructionStep
    markup: ->
      markup = super arguments...
      
      # Write diagonal ratios next to lines.
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtGrading = asset.pixelArtGrading()
      
      for line in pixelArtGrading.lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtGrading.Line.Part.StraightLine
        
        lineGrading = linePart.grade()
        
        unless lineGrading.type is StraightLine.Type.AxisAligned
          diagonalRatioText = Markup.PixelArt.diagonalRatioText linePart
          diagonalRatioText.text.style = @_getLineStyle lineGrading
          markup.push diagonalRatioText
        
      markup
      
    _getLineStyle: (lineGrading) ->
      if lineGrading.type in [StraightLine.Type.AxisAligned, StraightLine.Type.EvenDiagonal]
        Markup.betterStyle()
      
      else if lineGrading.pointSegmentLengths is StraightLine.SegmentLengths.Alternating
        Markup.mediocreStyle()
        
      else
        Markup.worseStyle()
  
  class @InstructionStepWithSegmentLines extends @InstructionStepWithDiagonalRatios
    markup: ->
      markup = super arguments...
      
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtGrading = asset.pixelArtGrading()
      
      for line in pixelArtGrading.lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtGrading.Line.Part.StraightLine
        
        # Add segment corner lines.
        lineGrading = linePart.grade()
        
        segmentCornersLineBase = Markup.PixelArt.intendedLineBase()
        segmentCornersLineBase.style = @_getLineStyle lineGrading
        
        segmentCorners = linePart.getSegmentCorners()
        
        for side in ['left', 'right']
          for point in segmentCorners[side]
            point.x += 0.5
            point.y += 0.5
          
          markup.push
            line: _.extend {}, segmentCornersLineBase,
              points: segmentCorners[side]
            
      markup
      
  class @ShallowAngles extends @InstructionStep
    @id: -> "#{Asset.id()}.ShallowAngles"
    @stepNumber: -> 1
    
    @message: -> """
      For angles close to horizontal and vertical, we can easily find even diagonals.
    """
    
    @initialize()
  
  class @OneToTwo extends @InstructionStep
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 2
    
    @message: -> """
      When we go from 1:3 to 1:2 diagonals, the angle gap becomes bigger.
    """
    
    @initialize()
  
  class @OneToOne extends @InstructionStep
    @id: -> "#{Asset.id()}.OneToOne"
    @stepNumber: -> 3
    
    @message: -> """
      The gap is the biggest between the 1:2 and 1:1 diagonals. There are no even lines in between in that range.
    """
    
    @initialize()
  
  class @Intermediary extends @InstructionStepWithDiagonalRatios
    @id: -> "#{Asset.id()}.Intermediary"
    @stepNumber: -> 4
    
    @message: -> """
      To close the gaps, we have to use intermediary diagonals, which alternate between different segment lengths.
    """
    
    @initialize()
  
  class @Complete extends @InstructionStepWithSegmentLines
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      Since the segments of uneven lines change in length, this leads to jaggies that don't align perfectly with the intended direction.
      
      For this reason, these angles are sometimes considered less aesthetic and avoided if possible, depending on the needs of the artwork and the chosen art style.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
