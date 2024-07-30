LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
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
  @pixelArtEvaluation: -> true
  
  @initialize()
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      markup = []
      
      for line in pixelArtEvaluation.layers[0].lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        # Add the perceived line.
        markup.push Markup.PixelArt.perceivedStraightLine linePart
        
      markup
  
  class @StepInstructionWithDiagonalRatios extends @StepInstruction
    markup: ->
      markup = super arguments...
      
      # Write diagonal ratios next to lines.
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      for line in pixelArtEvaluation.layers[0].lines
        # Draw this only for lines that are recognized as straight lines.
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        lineEvaluation = linePart.evaluate()
        
        unless lineEvaluation.type is StraightLine.Type.AxisAligned
          diagonalRatioText = Markup.PixelArt.diagonalRatioText linePart
          diagonalRatioText.text.style = @_getLineStyle lineEvaluation
          markup.push diagonalRatioText
        
      markup
      
    _getLineStyle: (lineEvaluation) ->
      if lineEvaluation.type in [StraightLine.Type.AxisAligned, StraightLine.Type.EvenDiagonal]
        Markup.betterStyle()
      
      else if lineEvaluation.pointSegmentLengths is StraightLine.SegmentLengths.Alternating
        Markup.mediocreStyle()
        
      else
        Markup.worseStyle()
  
  class @StepInstructionWithSegmentLines extends @StepInstructionWithDiagonalRatios
    markup: ->
      markup = super arguments...
      
      return markup unless asset = @getActiveAsset()
      return markup unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      for line in pixelArtEvaluation.layers[0].lines
        continue unless line.parts.length is 1
        linePart = line.parts[0]
        continue unless linePart instanceof PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
        
        # Add segment corner lines.
        lineEvaluation = linePart.evaluate()
        
        segmentCornersLineBase = Markup.PixelArt.perceivedLineBase()
        segmentCornersLineBase.style = @_getLineStyle lineEvaluation
        
        segmentCorners = linePart.getSegmentCorners()
        
        for side in ['left', 'right']
          for point in segmentCorners[side]
            point.x += 0.5
            point.y += 0.5
          
          markup.push
            line: _.extend {}, segmentCornersLineBase,
              points: segmentCorners[side]
            
      markup
      
  class @ShallowAngles extends @StepInstruction
    @id: -> "#{Asset.id()}.ShallowAngles"
    @stepNumber: -> 1
    
    @message: -> """
      For angles close to horizontal and vertical, we can easily find even diagonals.
    """
    
    @initialize()
  
  class @OneToTwo extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToTwo"
    @stepNumber: -> 2
    
    @message: -> """
      When we go from 1:3 to 1:2 diagonals, the angle gap becomes bigger.
    """
    
    @initialize()
  
  class @OneToOne extends @StepInstruction
    @id: -> "#{Asset.id()}.OneToOne"
    @stepNumber: -> 3
    
    @message: -> """
      The gap is the biggest between the 1:2 and 1:1 diagonals. There are no even lines in between that range.
    """
    
    @initialize()
  
  class @Intermediary extends @StepInstructionWithDiagonalRatios
    @id: -> "#{Asset.id()}.Intermediary"
    @stepNumber: -> 4
    
    @message: -> """
      To close the gaps, we have to use intermediary diagonals, which alternate between different segment lengths.
    """
    
    @initialize()
  
  class @Complete extends @StepInstructionWithSegmentLines
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
