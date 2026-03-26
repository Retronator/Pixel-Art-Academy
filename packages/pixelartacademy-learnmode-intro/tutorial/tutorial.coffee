LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial extends LM.Chapter
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial'
  
  @fullName: -> "Tutorial"
  @number: -> 1
  
  @sections: -> []

  @courses: -> [
    LM.Intro.Tutorial.Content.Course
  ]

  @initialize()

  constructor: ->
    super arguments...
    
    # Automatically select the Desktop editor.
    Tracker.autorun (computation) =>
      if PAA.PixelPad.Apps.Drawing.state 'editorId'
        computation.stop()
        return
        
      PAA.PixelPad.Apps.Drawing.state 'editorId', PAA.PixelPad.Apps.Drawing.Editor.Desktop.id()

    # Add intro goals to the Study Plan app.
    @_initializeStudyPlanAutorun = Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      return if PAA.PixelPad.Apps.StudyPlan.state 'goals'
      
      toDoTasksId = LM.Intro.Tutorial.Goals.ToDoTasks.id()
      pixelArtSoftwareId = LM.Intro.Tutorial.Goals.PixelArtSoftware.id()
      
      PAA.PixelPad.Apps.StudyPlan.state.set
        goals:
          "#{toDoTasksId}":
            connections: [
              goalId: pixelArtSoftwareId
              direction: PAA.PixelPad.Apps.StudyPlan.GoalConnectionDirections.Forward
            ]
          "#{pixelArtSoftwareId}": {}
        camera:
          scale: 1
          origin:
            x: 100
            y: 0
    
    # Create the snake project when the play task has been completed.
    @snakePlayTask = @getTask LM.Intro.Tutorial.Goals.Snake.Play
    @snakeDrawTask = @getTask LM.Intro.Tutorial.Goals.Snake.Draw

    @_createSnakeProjectAutorun = Tracker.autorun (computation) =>
      return unless @snakePlayTask.completed()
      return if PAA.Pico8.Cartridges.Snake.Project.state 'activeProjectId'
      return if @snakeDrawTask.completed()

      PAA.Pico8.Cartridges.Snake.Project.start().then =>
        # Reset high score to force replay.
        PAA.Pico8.Cartridges.Snake.state 'highScore', 0

  destroy: ->
    super arguments...

    @_initializeStudyPlanAutorun.stop()
    @_createSnakeProjectAutorun.stop()
    
  finished: ->
    # Tutorial ends when you complete the snake game goal.
    @getGoal(LM.Intro.Tutorial.Goals.Snake).completed() or false
