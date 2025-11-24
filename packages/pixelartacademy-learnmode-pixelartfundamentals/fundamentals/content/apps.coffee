PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Apps extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps'
  @displayName: -> "Apps"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @Music
    @Pixeltosh
    @Pixelvision
    @PixelKid
    @PixelFriend
    @StudyPlan
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
  
  class @Pixeltosh extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Pixeltosh'
    @appClass = PAA.PixelPad.Apps.Pixeltosh
    
    @unlockInstructions: -> "Complete the Element of art: line tutorial to unlock the Pixeltosh app."
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.pixeltoshEnabled() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
  
  class @Pixelvision extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.PixelVision'
    @displayName: -> "Pixelvision"
    @initialize()
  
  class @PixelKid extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.PixelKid'
    @displayName: -> "Pixel Kid"
    @initialize()
  
  class @PixelFriend extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.PixelFriend'
    @displayName: -> "Pixel Friend"
    @initialize()
    
  class @Music extends LM.Content.AppContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Music'
    @appClass = PAA.PixelPad.Apps.Music
    
    @unlockInstructions: -> "Complete the Pixel Art Tools course to unlock the Music app."
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.Start.finished() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
