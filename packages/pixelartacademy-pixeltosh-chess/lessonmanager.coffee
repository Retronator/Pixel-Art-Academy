PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.LessonManager
  constructor: (@chess) ->
    # Instantiate all the lesson categories.
    @_lessonCategories = (new categoryClass @ for categoryClass in Chess.Lesson.Category.getClasses())
    
    @lesson = new ReactiveField null
    @gameState = new ReactiveField null
    
    @rewinding = new ReactiveField false
    @moving = new ReactiveField false

  destroy: ->
    Meteor.clearTimeout @_rewindTimeout

    category.destroy() for category in @_lessonCategories
    
  availableCategories: ->
    availableCategories = _.filter @_lessonCategories, (category) => category.available()
    pieceCategories = _.filter availableCategories, (category) => category instanceof Chess.Lesson.PieceCategory
    otherCategories = _.difference availableCategories, pieceCategories
    
    # Order piece categories in purchase order.
    pieceCategoriesByPiece = {}
    pieceCategoriesByPiece[category.pieceType()] = category for category in pieceCategories
    orderedPieceCategories = (pieceCategoriesByPiece[piece] for piece of Chess.ownedPieceTypeCounts())

    # Show piece categories first, then other categories.
    [orderedPieceCategories..., otherCategories...]

  startLesson: (lesson) ->
    @lesson lesson
    startingGameState = lesson.startingGameState()
    @gameState startingGameState
    
    for piece in startingGameState.getPieces()
      return unless @chess.gameManager().assertDrawnPieces [piece.type], piece.color
    
    if startingGameState.turn() is Chess.Piece.Colors.Black
      @aiMove()

  endLesson: ->
    @lesson null
    @gameState null
  
  getLegalDestinationsFromSquare: (square) -> @gameState()?.getLegalDestinationsFromSquare square
  
  move: (move) ->
    Tracker.nonreactive =>
      @chess.audio.promote() if @_prePromotionGameState
      
      @_previousGameState = @_prePromotionGameState or @gameState()
      @_prePromotionGameState = null
      
      newGameState = @_previousGameState.applyMove move
      @gameState newGameState
      
      @chess.audioManager().announceState newGameState
      
      return if newGameState.finished()
      
      @aiMove()
      
  aiMove: ->
    gameState = @gameState()
    
    unless aiMove = @lesson().aiMove()
      gameState.setTurn Chess.Piece.Colors.White
      @gameState gameState
      return
    
    @moving true
    osCursor = @chess.os.cursor()
    osCursor.wait @
    
    await _.waitForSeconds 0.5
    
    newGameState = gameState.applyMove aiMove
    @gameState newGameState
    
    @chess.audioManager().announceState newGameState
    
    osCursor.endWait @
    @moving false
      
  startPromotion: (move) ->
    Tracker.nonreactive =>
      @_prePromotionGameState = @_previousGameState = @gameState()
      newGameState = @_prePromotionGameState.startPromotion move
      @gameState newGameState
    
  cancelPromotion: ->
    @gameState @_prePromotionGameState
    @_prePromotionGameState = null
  
  rewind: (gameState) ->
    Tracker.nonreactive =>
      return if @rewinding()
      @rewinding true
      
      await _.waitForSeconds if @moving() then 2 else 1
      
      @gameState gameState or @_previousGameState
      @rewinding false
      
      await _.waitForSeconds 0.5
      @chess.audioManager().tryAgain()
  
  humanCanMove: ->
    # Prevent movement while rewinding.
    return if @rewinding()
    
    # In the lessons, the player is always white.
    @gameState()?.turn() is Chess.Piece.Colors.White

  getChessboard: ->
    @chess.os.interface.getView Chess.Interface.Chessboard.Component
    
  getLessonView: ->
    @chess.os.interface.getView Chess.Interface.Lesson

  markup: ->
    return unless lessonView = @getLessonView()
    
    lessonView.activeStep()?.markup()
