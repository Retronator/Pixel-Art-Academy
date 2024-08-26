LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.ThickLines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.ThickLines"

  @displayName: -> "Thick lines"
  
  @description: -> """
    Thicker lines help with clear separation of shapes at the expense of using more space.
  """
  
  @bitmapInfo: -> """
    Artwork from [64x64 rpg](https://castpixel.artstation.com/projects/0XOaE8), 2019

    Artist: Christina 'castpixel' Neofotistou
  """
  
  @fixedDimensions: -> width: 36, height: 53
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/thicklines-#{step}.png" for step in [1..2]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/thicklines-template.png"
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # The first step should show invalid pixels even where the colors will add them later.
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    steps[0].options.canCompleteWithExtraPixels = true
    steps[1].options.hasPixelsWhenInactive = false
    
    # Once you complete the first step, don't return to it if you accidentally recolor some of its pixels later.
    steps[0].options.preserveCompleted = true
  
  Asset = @
  
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> Asset
    
  class @LineArt extends @StepInstruction
    @id: -> "#{Asset.id()}.LineArt"
    @stepNumber: -> 1
    
    @message: -> """
      Thick 1-pixel lines ensure there is always at least 1 pixel between the shapes on each side.
      This gives clarity to the areas in their definition and overlap but requires more space and a bolder appearance.
    """

    @initialize()
