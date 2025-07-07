LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Goals.Invasion extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Goals.Invasion'

  @displayName: -> "Invasion game"
  
  @chapter: -> LM.Design.Fundamentals

  Goal = @

  class @Play extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Goals.ShapeLanguage.Play'
    @goal: -> Goal
    
    @directive: -> "Play the game"
    
    @instructions: -> """
      In the PICO-8 app, try out the game Invasion.
      Score some points to continue.
    """
    
    @interests: -> ['pico-8', 'gaming']
    
    @requiredInterests: -> ['shape language']
    
    @initialize()
    
    @completedConditions: ->
      # Require score of 1 or higher. Since we reset the high score when the
      # invasion project is created, we also keep this task completed based on that.
      PAA.Pico8.Cartridges.Invasion.state('highScore') >= 1 or PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'

  @tasks: -> [
    @Play
  ]

  @finalTasks: -> [
    @Play
  ]

  @initialize()
