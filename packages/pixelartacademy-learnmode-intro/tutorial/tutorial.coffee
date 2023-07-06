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
      if PAA.PixelBoy.Apps.Drawing.state 'editorId'
        computation.stop()
        return
        
      PAA.PixelBoy.Apps.Drawing.state 'editorId', PAA.PixelBoy.Apps.Drawing.Editor.Desktop.id()

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

    @_createSnakeProjectAutorun.stop()
