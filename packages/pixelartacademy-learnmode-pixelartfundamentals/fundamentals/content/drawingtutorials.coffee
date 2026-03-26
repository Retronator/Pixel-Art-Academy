PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials'
  @displayName: -> "Drawing tutorials"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @ElementsOfArt
    @PixelArt
    @Simplification
    @GraphicalProjections
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
  
  status: -> @constructor.Status.Unlocked
    
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
      @initialize()
      
    class @Shape extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.ElementsOfArt.Shape'
      @tutorialClass = PAA.Tutorials.Drawing.ElementsOfArt.Shape
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
  
  class @PixelArt extends LM.Content
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt'
    @displayName: -> "Pixel art"
    @tags: -> [LM.Content.Tags.WIP]
    
    @contents: -> [
      @Lines
      @Diagonals
      @Curves
      @LineWidth
      @Shapes
      @Size
      @Rotation
      @LimitedPalettes
      @TechnicalLimitations
      @Aliasing
      @Dithering
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
    
    class @Lines extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Lines'
      @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines
      @initialize()
      
    class @Diagonals extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Diagonals'
      @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals
      @initialize()
    
    class @Curves extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Curves'
      @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves
      @initialize()
    
    class @LineWidth extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.LineWidth'
      @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth
      @initialize()
    
    class @Shapes extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Shapes'
      @displayName: -> "Pixel art shapes"
      @initialize()
    
    class @Size extends LM.Content.DrawingTutorialContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Size'
      @tutorialClass = PAA.Tutorials.Drawing.PixelArtFundamentals.Size
      @initialize()
    
    class @Rotation extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Rotation'
      @displayName: -> "Pixel art rotation"
      @initialize()
    
    class @LimitedPalettes extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.LimitedPalettes'
      @displayName: -> "Limited palettes"
      @initialize()
    
    class @TechnicalLimitations extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.TechnicalLimitations'
      @displayName: -> "Technical limitations"
      @initialize()
      
    class @Aliasing extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Aliasing'
      @displayName: -> "Aliasing"
      @initialize()
    
    class @Dithering extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArt.Dithering'
      @displayName: -> "Dithering"
      @initialize()
      
  class @Simplification extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.Simplification'
    @tutorialClass = PAA.Tutorials.Drawing.Simplification
    @initialize()
    
  class @GraphicalProjections extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.GraphicalProjections'
    @displayName: -> "Graphical projections"
    
    @contents: -> [
      @Multiview
      @PixelIsometric
    ]
    
    @initialize()
  
    status: -> @constructor.Status.Unlocked
    
    class @Multiview extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.GraphicalProjections.Multiview'
      @displayName: -> "Multiview"
      @initialize()
  
    class @PixelIsometric extends LM.Content.FutureContent
      @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.GraphicalProjections.PixelIsometric'
      @displayName: -> "Pixel isometric"
      @initialize()
