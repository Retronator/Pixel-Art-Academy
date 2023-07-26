PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Goals extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals'
  @displayName: -> "Study goals"
  @contents: -> [
    @LowResRasterArt
    @Jaggies
    @Aliasing
    @Dithering
    @ScaleSelection
  ]
  @initialize()

  class @LowResRasterArt extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt'
    @displayName: -> "Low-resolution raster art"
    @contents: -> [
      @LearnRasterMediums
      @LearnLowResRasterArt
    ]
    @initialize()
    
    class @LearnRasterMediums extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt-PixelArtAcademy.StudyGuide.LowResRasterArt.LearnRasterMediums'
      @displayName: -> "Learn about raster mediums"
      @initialize()
    
    class @LearnLowResRasterArt extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt-PixelArtAcademy.StudyGuide.LowResRasterArt.LearnLowResRasterArt'
      @displayName: -> "Learn about low-resolution raster art"
      @initialize()
    
  class @Jaggies extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies'
    @displayName: -> "Jaggies"
    @contents: -> [
      @LearnJaggies
      @PracticeDiagonals
      @PracticeCurves
    ]
    @initialize()
    
    class @LearnJaggies extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies-PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies.LearnJaggies'
      @displayName: -> "Learn about jaggies"
      @initialize()

    class @PracticeDiagonals extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies-PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies.PracticeDiagonals'
      @displayName: -> "Practice drawing diagonals"
      @initialize()

    class @PracticeCurves extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies-PixelArtAcademy.StudyGuide.LowResRasterArt.Jaggies.PracticeCurves'
      @displayName: -> "Practice drawing curves"
      @initialize()
  
  class @Aliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing'
    @displayName: -> "Aliasing"
    @contents: -> [
      @LearnAliasing
      @AntiAliasedLetters
    ]
    @initialize()
    
    class @LearnAliasing extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing-PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing.LearnAliasing'
      @displayName: -> "Learn about aliasing"
      @initialize()
    
    class @AntiAliasedLetters extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing-PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing.AntiAliasedLetters'
      @displayName: -> "Draw anti-aliased letters"
      @initialize()
      
  class @Dithering extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering'
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
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.LearnDithering'
      @displayName: -> "Learn about dithering"
      @initialize()
    
    class @Ordered extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.Ordered'
      @displayName: -> "Draw a sky gradient with ordered dithering"
      @initialize()
    
    class @Diffusion extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.Diffusion'
      @displayName: -> "Draw a vignette effect with diffusion dithering"
      @initialize()
    
    class @Noise extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.Noise'
      @displayName: -> "Shade a rough surface with noise dithering"
      @initialize()
    
    class @Stylized extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.Stylized'
      @displayName: -> "Mix colors with stylized dithering"
      @initialize()
    
    class @ColorCount extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.ColorCount'
      @displayName: -> "Draw a gradient with different color counts"
      @initialize()
    
    class @Quantity extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.Quantity'
      @displayName: -> "Use dithering for different purposes"
      @initialize()

    class @Transparency extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering-PixelArtAcademy.StudyGuide.LowResRasterArt.Dithering.Transparency'
      @displayName: -> "Add a translucent volume to a scene"
      @initialize()
      
  class @ScaleSelection extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.ScaleSelection'
    @displayName: -> "Scale selection"
    @contents: -> [
      @LearnScaleSelection
      @DifferentScales
    ]
    @initialize()
    
    class @LearnScaleSelection extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing-PixelArtAcademy.StudyGuide.LowResRasterArt.ScaleSelection.LearnScaleSelection'
      @displayName: -> "Learn how to select scale"
      @initialize()
    
    class @DifferentScales extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.StudyGuide.LowResRasterArt.Aliasing-PixelArtAcademy.StudyGuide.LowResRasterArt.ScaleSelection.DifferentScales'
      @displayName: -> "Draw a character at different scales"
      @initialize()
