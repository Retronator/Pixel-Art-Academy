PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Content.DrawingTutorials extends LM.Content
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.DrawingTutorials'

  @displayName: -> "Drawing tutorials"
  @tags: -> [LM.Content.Tags.WIP]
  @contents: -> [
    @ShapeLanguage
    @ColorSchemes
    @Composition
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

  class @ShapeLanguage extends LM.Content.DrawingTutorialContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.DrawingTutorials.ShapeLanguage'
    @tutorialClass = PAA.Tutorials.Drawing.Design.ShapeLanguage

    @initialize()
    
  class @ColorSchemes extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.DrawingTutorials.ColorSchemes'
    @displayName: -> "Color schemes"
    @initialize()
  
  class @Composition extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Content.DrawingTutorials.Composition'
    @displayName: -> "Composition"
    @initialize()
