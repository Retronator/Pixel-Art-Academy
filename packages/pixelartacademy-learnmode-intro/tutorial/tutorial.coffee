LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial extends PAA.Chapter
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial'
  
  @fullName: -> "Tutorial"
  @number: -> 1
  
  @sections: -> []
  
  @initialize()

  constructor: ->
    super arguments...

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
