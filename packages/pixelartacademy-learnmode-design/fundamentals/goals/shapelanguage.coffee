LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Goals.ShapeLanguage extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Goals.ShapeLanguage'

  @displayName: -> "Shape language"
  
  @chapter: -> LM.Design.Fundamentals

  Goal = @

  class @Learn extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Goals.ShapeLanguage.Learn'
    @goal: -> Goal

    @directive: -> "Learn shape language"

    @instructions: -> """
      In the Drawing app, complete the Shape language tutorial to learn what characteristics basic shapes convey.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
  
    @requiredInterests: -> ['shape']

    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.Design.ShapeLanguage.completed()

  @tasks: -> [
    @Learn
  ]

  @finalTasks: -> [
    @Learn
  ]

  @initialize()
