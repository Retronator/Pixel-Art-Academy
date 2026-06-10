LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard'
  @register @id()

  @Providers:
    GameManager: 'gameManager'
    LessonManager: 'lessonManager'
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @chess = @os.getProgram Chess
  
  boardDisplayType: -> Chess.boardDisplayType()
