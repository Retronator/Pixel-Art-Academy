PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Apps extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps'

  @displayName: -> "Apps"

  @contents: -> [
    @StudyPlan
    @StudyGuide
    @Arcade
    @Pixeltosh
    @ZXSpectrum
  ]

  @initialize()

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      units: "apps"

  status: -> LM.Content.Status.Unlocked

  class @StudyPlan extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.StudyPlan'
    @displayName: -> "Study Plan"
    @initialize()

  class @StudyGuide extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.StudyGuide'
    @displayName: -> "Study Guide"
    @initialize()
    
  class @Arcade extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Arcade'
    @displayName: -> "Arcade"
    @initialize()
  
  class @Pixeltosh extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Pixeltosh'
    @displayName: -> "Pixeltosh"
    @initialize()
  
  class @ZXSpectrum extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.ZXSpectrum'
    @displayName: -> "ZX Spectrum"
    @initialize()
