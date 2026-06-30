PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.EndStep extends Chess.Lesson.Step
  template: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lesson.EndStep'

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
    
  completed: -> true
  
  events: ->
    super(arguments...).concat
      'click .end-button': @onClickEndButton

  onClickEndButton: (event) ->
    @chess.audioManager().lessonComplete()
    @chess.interfaceManager().enterScreen Chess.InterfaceManager.Screens.Menu
