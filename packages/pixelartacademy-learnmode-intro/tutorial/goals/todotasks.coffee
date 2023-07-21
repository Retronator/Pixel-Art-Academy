LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.ToDoTasks extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks'

  @displayName: -> "To-do tasks"

  @chapter: -> LM.Intro.Tutorial

  Goal = @
  
  class @OpenInstructions extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks.OpenInstructions'
    @goal: -> Goal

    @directive: -> "Click here to read task instructions"

    @instructions: -> """
      This notepad will keep track of your current tasks.
      You can always click on a task to learn how to complete it.

      Click on the arrow to get back to the tasks.
    """
  
    @initialize()

    @completedConditions: ->
      # Instructions for this task have to be open.
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless toDoSystem = _.find pixelPad.os.currentSystems(), (system) => system instanceof PAA.PixelPad.Systems.ToDo
      return unless toDoSystem.isCreated()
      
      toDoSystem.selectedTask() instanceof @
      
  class @ReceiveDrawingApp extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.ToDoTasks.ReceiveDrawingApp'
    @goal: -> Goal

    @directive: -> "Receive the drawing app"

    @instructions: -> """
      You now have access to the main app where you will practice drawing.
    """
  
    @predecessors: -> [Goal.OpenInstructions]
    
    @interests: -> ['to-do tasks']
    
    @initialize()

    @completedConditions: ->
      # Instructions for the previous task have to be closed.
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless toDoSystem = _.find pixelPad.os.currentSystems(), (system) => system instanceof PAA.PixelPad.Systems.ToDo
      return unless toDoSystem.isCreated()
      
      not toDoSystem.selectedTask()

  @tasks: -> [
    @OpenInstructions
    @ReceiveDrawingApp
  ]

  @finalTasks: -> [
    @ReceiveDrawingApp
  ]

  @initialize()
