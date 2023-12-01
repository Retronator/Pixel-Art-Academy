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
      In the Drawing app, complete the pixel art lines tutorial to learn about jaggies.
    """
    
    @requiredInterests: -> ['line']

    @icon: -> PAA.Learning.Task.Icons.Drawing
  
    @initialize()
    
    @completedConditions: ->
      PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()

  @tasks: -> [
    @Lines
  ]

  @finalTasks: -> [
    @Lines
  ]

  @initialize()
