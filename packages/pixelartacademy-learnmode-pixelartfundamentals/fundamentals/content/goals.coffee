PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Goals extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals'
  @displayName: -> "Study goals"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @ElementsOfArt
    @LowResRasterArt
    @Jaggies
    @Aliasing
    @Dithering
    @ScaleSelection
  ]
  @initialize()
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 2
      requiredUnits: "goals"
      totalUnits: "tasks"
      totalRecursive: true
  
  status: ->
    # Goals unlock after the episode's start scene is finished.
    if LM.PixelArtFundamentals.Start.finished() then @constructor.Status.Unlocked else @constructor.Status.Locked

  class @ElementsOfArt extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt'
    @goalClass = LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt
    @tags: -> [LM.Content.Tags.WIP]
    
    @contents: ->
      super(arguments...).concat [
        @Shape
        @Form
        @Space
        @Value
        @Color
        @Texture
      ]
      
    @initialize()
    
    class @Shape extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt.Shape'
      @displayName: -> "Learn about shape"
      @initialize()
    
    class @Form extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt.Form'
      @displayName: -> "Learn about form"
      @initialize()
    
    class @Space extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt.Space'
      @displayName: -> "Learn about space"
      @initialize()
    
    class @Value extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt.Value'
      @displayName: -> "Learn about value"
      @initialize()
    
    class @Color extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt.Color'
      @displayName: -> "Learn about color"
      @initialize()
    
    class @Texture extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt.Texture'
      @displayName: -> "Learn about texture"
      @initialize()

  class @LowResRasterArt extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt'
    @displayName: -> "Low-resolution raster art"
    @contents: -> [
      @LearnRasterMediums
      @LearnLowResRasterArt
    ]
    @initialize()
    
    class @LearnRasterMediums extends LM.Content.FutureContent
      @id: -> 'PPixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.LearnRasterMediums'
      @displayName: -> "Learn about raster mediums"
      @initialize()
    
    class @LearnLowResRasterArt extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.LearnLowResRasterArt'
      @displayName: -> "Learn about low-resolution raster art"
      @initialize()
    
  class @Jaggies extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Jaggies'
    @displayName: -> "Jaggies"
    @contents: -> [
      @LearnJaggies
      @PracticeDiagonals
      @PracticeCurves
    ]
    @initialize()
    
    class @LearnJaggies extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Jaggies.LearnJaggies'
      @displayName: -> "Learn about jaggies"
      @initialize()

    class @PracticeDiagonals extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Jaggies.PracticeDiagonals'
      @displayName: -> "Practice drawing diagonals"
      @initialize()

    class @PracticeCurves extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Jaggies.PracticeCurves'
      @displayName: -> "Practice drawing curves"
      @initialize()
  
  class @Aliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Aliasing'
    @displayName: -> "Aliasing"
    @contents: -> [
      @LearnAliasing
      @AntiAliasedLetters
    ]
    @initialize()
    
    class @LearnAliasing extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Aliasing.LearnAliasing'
      @displayName: -> "Learn about aliasing"
      @initialize()
    
    class @AntiAliasedLetters extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Aliasing.AntiAliasedLetters'
      @displayName: -> "Draw anti-aliased letters"
      @initialize()
      
  class @Dithering extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering'
    @displayName: -> "Dithering"
    @contents: -> [
      @LearnDithering
      @Ordered
      @Diffusion
      @Noise
      @Stylized
      @ColorCount
      @Quantity
      @Transparency
    ]
    @initialize()
    
    class @LearnDithering extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.LearnDithering'
      @displayName: -> "Learn about dithering"
      @initialize()
    
    class @Ordered extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.Ordered'
      @displayName: -> "Draw a sky gradient with ordered dithering"
      @initialize()
    
    class @Diffusion extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.Diffusion'
      @displayName: -> "Draw a vignette effect with diffusion dithering"
      @initialize()
    
    class @Noise extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.Noise'
      @displayName: -> "Shade a rough surface with noise dithering"
      @initialize()
    
    class @Stylized extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.Stylized'
      @displayName: -> "Mix colors with stylized dithering"
      @initialize()
    
    class @ColorCount extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.ColorCount'
      @displayName: -> "Draw a gradient with different color counts"
      @initialize()
    
    class @Quantity extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.Quantity'
      @displayName: -> "Use dithering for different purposes"
      @initialize()

    class @Transparency extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Dithering.Transparency'
      @displayName: -> "Add a translucent volume to a scene"
      @initialize()
      
  class @ScaleSelection extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.ScaleSelection'
    @displayName: -> "Scale selection"
    @contents: -> [
      @LearnScaleSelection
      @DifferentScales
    ]
    @initialize()
    
    class @LearnScaleSelection extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Aliasing-PixelArtAcademy.StudyGuide.LowResRasterArt.ScaleSelection.LearnScaleSelection'
      @displayName: -> "Learn how to select scale"
      @initialize()
    
    class @DifferentScales extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.LowResRasterArt.Aliasing-PixelArtAcademy.StudyGuide.LowResRasterArt.ScaleSelection.DifferentScales'
      @displayName: -> "Draw a character at different scales"
      @initialize()
