LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.VaryingLineWidth extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.VaryingLineWidth"

  @displayName: -> "Varying line width"
  
  @description: -> """
    Lines do not need a fixed width at all.
  """
  
  @bitmapInfo: -> """
    Artwork from [Arclands](https://arclands.de), WIP

    Artist: Jon Keller
  """
  
  @fixedDimensions: -> width: 48, height: 55
  
  @steps: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/varyinglinewidth-#{step}.png" for step in [1..2]
  
  @customPaletteImageUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/linewidth/varyinglinewidth-template.png"
  
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
  
  class @LineArt extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.LineArt"
    @assetClass: -> Asset
    
    @message: -> """
      There are many reasons to vary line width for art direction purposes.
      Without going deeper into the topic for now, observe how Arclands uses 2-pixel lines for depth separation but tapers them at their ends, while also using 1-pixel details on the inside.
    """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the asset is completed.
      not asset.completed()
      
    @initialize()
