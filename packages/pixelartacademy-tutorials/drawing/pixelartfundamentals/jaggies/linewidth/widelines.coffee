LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.WideLines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.WideLines"

  @displayName: -> "Wide lines"
  
  @description: -> """
    2-pixel lines offer an even bigger clarity of shapes.
  """
  
  @bitmapInfo: -> """
    Artwork from [Die in the Dungeon](https://store.steampowered.com/app/2026820/Die_in_the_Dungeon/), WIP

    Artist: Álvaro Farfán
  """
  
  @fixedDimensions: -> width: 33, height: 51
  @backgroundColor: -> new THREE.Color '#b09d87'
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/widelines-#{step}.png" for step in [1..2]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/widelines-template.png"
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # The first step should show invalid pixels even where the colors will add them later.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
    steps[1].options.hasPixelsWhenInactive = false
    
    # Second step changes the lineart colors of the first step.
    steps[0].options.preserveCompleted = true
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
  class @LineArt extends @StepInstruction
    @id: -> "#{Asset.id()}.LineArt"
    @stepNumber: -> 1
    
    @message: -> """
      Given enough space, 2-pixel lines give the sprites from Die in the Dungeon a standout, cartoony look.
      The extra width gives the lines space to breathe, sharing the softer appearance of thin lines.
    """

    @initialize()

  class @ColoredLines extends @StepInstruction
    @id: -> "#{Asset.id()}.ColoredLines"
    @stepNumber: -> 2
    
    @message: -> """
      The art style of Die in the Dungeon also employs shaded outlines, which will be further explored in art direction lessons.
      Recolor the outlines as required.
    """
    
    @initialize()
