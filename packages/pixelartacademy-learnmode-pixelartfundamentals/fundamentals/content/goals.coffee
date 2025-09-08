PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Goals extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals'
  @displayName: -> "Study goals"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @ElementsOfArt
    @Jaggies
    @Pinball
    @Simplification
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
  
  status: -> @constructor.Status.Unlocked

  class @ElementsOfArt extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.ElementsOfArt'
    @goalClass = LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt
    @tags: -> [LM.Content.Tags.WIP]
    @initialize()
    
  class @Jaggies extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.Jaggies'
    @goalClass = LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies
    
    @unlockInstructions: -> "Complete the Elements of art: line tutorial to learn about pixel art lines."
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Line.getAdventureInstance()?.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
  
  class @Pinball extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.Pinball'
    @goalClass = LM.PixelArtFundamentals.Fundamentals.Goals.Pinball
    @tags: -> [LM.Content.Tags.WIP]
    
    @unlockInstructions: -> "Complete the Smooth curves challenge to start creating your own pinball machine."
  
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.pinballEnabled() then LM.Content.Status.Unlocked else LM.Content.Status.Locked

  class @Simplification extends LM.Content.GoalContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Goals.Simplification'
    @goalClass = LM.PixelArtFundamentals.Fundamentals.Goals.Simplification
    @tags: -> [LM.Content.Tags.WIP]
    
    @unlockInstructions: -> "Complete the Elements of art: shape tutorial to unlock the Simplification study goal."
    
    @initialize()
    
    status: -> if LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Shape.completed() then LM.Content.Status.Unlocked else LM.Content.Status.Locked
