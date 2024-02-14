LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies'

  @displayName: -> "Pixel art fundamentals: jaggies"
  
  @chapter: -> LM.PixelArtFundamentals.Fundamentals

  Goal = @

  class @Lines extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Lines'
    @goal: -> Goal

    @directive: -> "Learn about lines in pixel art"

    @instructions: -> """
      In the Drawing app, complete the Pixel art lines tutorial to learn about jaggies.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['line']
    
    @interests: -> ['pixel art line']
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
  
  class @Diagonals extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Diagonals'
    @goal: -> Goal
    
    @directive: -> "Learn about diagonals in pixel art"
    
    @instructions: -> """
      In the Drawing app, complete the Pixel art diagonals tutorial to learn about how different angles affect the patterns of jaggies.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['pixel art line']
    
    @interests: -> ['pixel art diagonal']
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> -1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed()
  
  class @Curves extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Goals.Jaggies.Curves'
    @goal: -> Goal
    
    @directive: -> "Learn about curves in pixel art"
    
    @instructions: -> """
      In the Drawing app, complete the Pixel art curves tutorial to learn what makes lines appear smooth.
    """
    
    @icon: -> PAA.Learning.Task.Icons.Drawing
    
    @requiredInterests: -> ['pixel art line']
    
    @interests: -> ['pixel art curve']
    
    @predecessors: -> [Goal.Lines]
    
    @groupNumber: -> 1
    
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed()
  
  @tasks: -> [
    @Lines
    @Diagonals
  ]

  @finalTasks: -> [
    @Diagonals
  ]

  @initialize()
