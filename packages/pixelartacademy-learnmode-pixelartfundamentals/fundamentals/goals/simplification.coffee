LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Simplification extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Simplification'

  @displayName: -> "Simplification"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Tutorial extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Simplification.Tutorial'
    @goal: -> Goal

    @directive: -> "Learn about simplification"

    @instructions: -> """
      In the Drawing app, complete the Simplification tutorial to learn how to intentionally simplify your drawings.
    """

    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['shape']
  
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.Simplification.completed()
    
    Task = @
    
  class @Challenge extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Simplification.Challenge'
    @goal: -> Goal
    
    @directive: -> "Draw quickly"
    
    @instructions: -> """
      In the Pixeltosh app, launch the game Draw Quickly and try both symbolic drawing and realistic drawing.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @predecessors: -> [Goal.Tutorial]
    
    @initialize()
    
    @completedConditions: ->
      # TODO: Set to completed when the draw quickly challenge is completed.
      false
    
    Task = @

  @tasks: -> [
    @Tutorial
    @Challenge
  ]

  @finalTasks: -> [
    @Challenge
  ]

  @initialize()
