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
  
  initializeSteps: ->
    super arguments...
    
    # Allow steps to complete with extra pixels so that we can show only line ends, but continue with a line drawn.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
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
   
  class @DrawLine extends @StepInstruction
    @id: -> "#{Asset.id()}.DrawLine"
    @stepNumber: -> 1
    
    @message: -> """
      Connect the two dots with a line using the pencil's line-drawing capability (shift + click).
    """
    
    @initialize()
  
  class @Cleanup extends @StepInstruction
    @id: -> "#{Asset.id()}.Cleanup"
    @stepNumber: -> 2
    
    @message: -> """
      The most common algorithm used for drawing lines in raster art (Bresenham's line algorithm) doesn't create even
      diagonals since it tries to make the starting and ending segments shorter (to enable connecting multiple lines in
      a row). You'll have to manually clean up such lines.
    """
    
    @initialize()
  
  class @ConstrainAngle extends @StepInstruction
    @id: -> "#{Asset.id()}.ConstrainAngle"
    @stepNumbers: -> [3, 4]
    
    @message: -> """
      To be more efficient, when holding down shift to draw a line, you can constrain the angle to even diagonals by also holding down cmd/ctrl.
    """
    
    @initialize()