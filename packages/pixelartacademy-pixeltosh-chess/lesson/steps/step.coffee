AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Lesson.Step extends AM.Component
  @retryMessage: -> # Override if the step has a message for failed attempts.
  @retryPosition: -> # Override to retry from a specific position after failure.
  
  @retryGameState: ->
    return unless retryPosition = @retryPosition()
    
    Chess.GameState.fromPosition retryPosition

  @initialize: ->
    @register @id()
    
    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty
        
        # Create this instruction's translated names.
        translationNamespace = @id()
        
        for property in ['message', 'retryMessage']
          continue unless value = @[property]()
          AB.createTranslation translationNamespace, property, value
          
  template: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Lesson.Step'
  
  constructor: (@lesson) ->
    super arguments...
    
    @_id = @id()
  
  onCreated: ->
    super arguments...
    
    @retrying = new ReactiveField false
    
    @autorun (computation) =>
      return unless @failed()
      computation.stop()
      
      @retrying true

  id: -> @constructor.id()
  retryGameState: -> @constructor.retryGameState()
  
  message: -> @translate('message').text
  messageTranslation: -> @translation 'message'
  
  retryMessage: -> @translate('retryMessage').text
  retryMessageTranslation: -> @translation 'retryMessage'
  
  completed: -> throw new AE.NotImplementedException "A step must specify when it is completed."

  failed: -> # Override if it's possible to reach a failed state.

  markup: -> # Override to provide chessboard markup.
  
  gameState: -> @lesson.lessonManager.gameState()

  chessboard: -> @lesson.lessonManager.getChessboard()

  positionAchieved: (position) ->
    return unless gameState = @gameState()

    for squareName, pieceLetter of position
      square = Chess.Square[squareName]

      if pieceLetter
        return unless gameState.hasPieceAtSquare Chess.Piece.fromLetter(pieceLetter), square

      else
        return if gameState.isSquareOccupied square

    true
