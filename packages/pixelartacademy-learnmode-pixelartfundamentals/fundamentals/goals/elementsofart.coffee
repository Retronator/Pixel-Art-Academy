LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt'

  @displayName: -> "Elements of art"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Line extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt.Line'
    @goal: -> Goal

    @directive: -> "Learn about lines"

    @instructions: -> """
      In the Drawing app, complete the Elements of art: line tutorial to learn about the most foundational element of art.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @interests: -> ['line']
  
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
    
    Task = @
    
  @tasks: -> [
    @Line
  ]

  @finalTasks: -> [
    @Line
  ]

  @initialize()
