PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials'
  @displayName: -> "Drawing tutorials"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @ElementsOfArt
    @Diagonals
    @Curves
    @AntiAliasing
    @Dithering
    @Rotation
    @Scale
  ]
  @initialize()
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Content.Progress.ContentProgress
      content: @
      weight: 3
      requiredUnits: "tutorials"
      totalUnits: "tutorial steps"
      totalRecursive: true
  
  status: ->
    toDoTasksGoal = PAA.Learning.Goal.getAdventureInstanceForId LM.Intro.Tutorial.Goals.ToDoTasks.id()
    if toDoTasksGoal.completed() then @constructor.Status.Unlocked else @constructor.Status.Locked
    
  class @ElementsOfArt extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt'
    @displayName: -> "Elements of art"
    @tags: -> [LM.Content.Tags.WIP]
    
    @contents: -> [
      @Line
      @Shape
      @Form
      @Space
      @Value
      @Color
      @Texture
    ]
    
    @initialize()
    
    constructor: ->
      super arguments...
    
      @progress = new LM.Content.Progress.ContentProgress
        content: @
        requiredUnits: "tutorials"
        totalUnits: "tutorial steps"
        totalRecursive: true
    
    status: -> @constructor.Status.Unlocked
    
    class @Line extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Line'
      @tutorialClass = PAA.Tutorials.Drawing.ElementsOfArt.Line
      @tags: -> [LM.Content.Tags.WIP]
      @initialize()
      
    class @Shape extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Shape'
      @displayName: -> "Elements of art: shape"
      @initialize()
    
    class @Form extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Form'
      @displayName: -> "Elements of art: form"
      @initialize()
    
    class @Space extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Space'
      @displayName: -> "Elements of art: space"
      @initialize()
    
    class @Value extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Value'
      @displayName: -> "Elements of art: value"
      @initialize()
    
    class @Color extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Color'
      @displayName: -> "Elements of art: color"
      @initialize()
    
    class @Texture extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Texture'
      @displayName: -> "Elements of art: texture"
      @initialize()
      
  class @Diagonals extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Diagonals'
    @displayName: -> "Pixel art diagonals"
    @initialize()
  
  class @Curves extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Curves'
    @displayName: -> "Pixel art curves"
    @initialize()
  
  class @AntiAliasing extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.AntiAliasing'
    @displayName: -> "Anti-aliasing"
    @initialize()
  
  class @Dithering extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Dithering'
    @displayName: -> "Dithering"
    @initialize()
  
  class @Rotation extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Rotation'
    @displayName: -> "Pixel art rotation"
    @initialize()
    
  class @Scale extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Scale'
    @displayName: -> "Pixel art scale"
    @initialize()
