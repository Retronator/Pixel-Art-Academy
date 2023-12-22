LOI = LandsOfIllusions
PAA = PixelArtAcademy

StraightLine = PAA.Practice.PixelArtEvaluation.Line.Part.StraightLine
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.ConstrainingAngles extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.ConstrainingAngles"

  @displayName: -> "Constraining line angles"
  
  @description: -> """
    Speed up drawing of even diagonals.
  """
  
  @fixedDimensions: -> width: 23, height: 15
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/constrainingangles-#{step}.png" for step in [1..5]
  
  @markup: -> true
  
  @initialize()
  
  Asset = @
  
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumbers: -> throw new AE.NotImplementedException "Instruction step must provide the step numbers."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      stepNumbers = @stepNumbers()
      stepNumbers = [stepNumbers] unless _.isArray stepNumbers
      
      # Show with the correct step.
      return unless asset.stepAreas()[0].activeStepIndex() + 1 in stepNumbers

      # Show until the asset is completed.
      not asset.completed()
    
    @resetDelayOnOperationExecuted: -> true
    
    markup: ->
      return unless asset = @getActiveAsset()
      return unless bitmap = asset.bitmap()
      
      markup = []
      
      # Highlight uneven pixels.
      unevenPixelBase = style: Markup.errorStyle()
      
      for x in [bitmap.bounds.left..bitmap.bounds.right]
        for y in [bitmap.bounds.top..bitmap.bounds.bottom]
          # Uneven pixels can only exist where pixels are placed.
          continue unless bitmap.findPixelAtAbsoluteCoordinates x, y
          
          # If we don't need a pixel here, it's uneven.
          continue if asset.hasGoalPixel x, y
          
          markup.push pixel: _.extend {x, y}, unevenPixelBase
          
      markup
   
  class @DrawLine extends @InstructionStep
    @id: -> "#{Asset.id()}.DrawLine"
    @stepNumbers: -> 1
    
    @message: -> """
      Connect the two dots with a line using the pencil's line-drawing capability (shift + click).
    """
    
    @initialize()
  
  class @Cleanup extends @InstructionStep
    @id: -> "#{Asset.id()}.Cleanup"
    @stepNumbers: -> 2
    
    @message: -> """
      The most common algorithm used for drawing lines in raster art (Bresenham's line algorithm) doesn't create even
      diagonals since it tries to make the starting and ending segments shorter (to enable connecting multiple lines in
      a row). You'll have to manually clean up such lines.
    """
    
    @initialize()
  
  class @ConstrainAngle extends @InstructionStep
    @id: -> "#{Asset.id()}.ConstrainAngle"
    @stepNumbers: -> [3, 4]
    
    @message: -> """
      To be more efficient, when holding down shift to draw a line, you can constrain the angle to even diagonals by also holding down cmd/ctrl.
    """
    
    @initialize()
