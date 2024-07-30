PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Apps extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps'
  @displayName: -> "Apps"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @Music
    @Pixeltosh
    @StudyPlan
    @Arcade
    @ZXSpectrum
  ]
  @initialize()
  
  status: -> LM.Content.Status.Unlocked

  constructor: ->
    super arguments...

    @progress = new LM.Content.Progress.ContentProgress
      content: @
      units: "apps"

  class @StudyPlan extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.StudyPlan'
    @displayName: -> "Study Plan"
    @initialize()
    
  class @Arcade extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Arcade'
    @displayName: -> "Arcade"
    @initialize()
  
  class @Pixeltosh extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Pixeltosh'
    @appClass = PAA.PixelPad.Apps.Pixeltosh
    
    @unlockInstructions: -> "Complete the Smooth curves challenge to unlock the Pixeltosh app."
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.pinballEnabled() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
  
  class @ZXSpectrum extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.ZXSpectrum'
    @displayName: -> "ZX Spectrum"
    @initialize()
    
  class @Music extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Music'
    @appClass = PAA.PixelPad.Apps.Music
    
    @unlockInstructions: -> "Complete the Pixel Art Tools course to unlock the Music app."
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.Start.finished() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
