PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.LessonManager
  constructor: (@chess) ->
    # Instantiate all the lesson categories.
    @_lessonCategories = (new categoryClass @ for categoryClass in Chess.Lesson.Category.getClasses())
    
    @lesson = new ReactiveField null
    @gameState = new ReactiveField null

  destroy: ->
    category.destroy() for category in @_lessonCategories
    
  availableCategories: ->
    return unless gameManager = @chess.gameManager()

    availableCategories = _.filter @_lessonCategories, (category) => category.available()
    pieceCategories = _.filter availableCategories, (category) => category instanceof Chess.Lesson.PieceCategory
    otherCategories = _.difference availableCategories, pieceCategories
    
    # Order piece categories in purchase order.
    pieceCategoriesByPiece = {}
    pieceCategoriesByPiece[category.pieceType()] = category for category in pieceCategories
    orderedPieceCategories = (pieceCategoriesByPiece[piece] for piece of gameManager.ownedPieceTypeCounts())

    # Show piece categories first, then other categories.
    [orderedPieceCategories..., otherCategories...]

  startLesson: (lesson) ->
    @lesson lesson
    @gameState lesson.startingGameState()

  endLesson: ->
    @lesson null
    @gameState null
  
  getLegalMovesFromSquare: (square) -> @gameState()?.getLegalMovesFromSquare square
  
  move: (move) ->
    @gameState @gameState().applyMove move
  
  humanCanMove: ->
    # In the lessons, the player is always white.
    @gameState()?.turn() is Chess.Piece.Colors.White

  getChessboard: ->
    @chess.os.interface.getView Chess.Interface.Chessboard
    
  getLessonView: ->
    @chess.os.interface.getView Chess.Interface.Lesson

  markup: ->
    return unless lessonView = @getLessonView()
    
    lessonView.activeStep()?.markup()
