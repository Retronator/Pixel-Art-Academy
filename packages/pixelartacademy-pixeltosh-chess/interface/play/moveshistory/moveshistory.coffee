AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Play.MovesHistory extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Play.MovesHistory'
  @register @id()

  onCreated: ->
    super arguments...

    @play = @ancestorComponentOfType Chess.Interface.Play
    @chess = @play.chess

  onRendered: ->
    super arguments...

    @autorun =>
      plyHistoryLength = @chess.gameManager().plyHistory().length

      if @_previousPlyHistoryLength? and plyHistoryLength > @_previousPlyHistoryLength
        Tracker.afterFlush => Meteor.setTimeout =>
          scrollableArea = @childComponentsOfType(PAA.Pixeltosh.OS.Interface.ScrollableArea)[0]
          scrollableArea.scrollToBottom()

      @_previousPlyHistoryLength = plyHistoryLength

  scrollbars: ->
    vertical:
      enabled: true

  moves: ->
    plyHistory = @chess.gameManager().plyHistory()

    for whitePlyNumber in [1...plyHistory.length] by 2
      whitePly = plyHistory[whitePlyNumber]

      plies = [
        ply: whitePly
        previousGameState: plyHistory[whitePlyNumber - 1].gameState
        color: Chess.Piece.Colors.White
      ]

      if blackPly = plyHistory[whitePlyNumber + 1]
        plies.push
          ply: blackPly
          previousGameState: whitePly.gameState
          color: Chess.Piece.Colors.Black

      moveNumber: (whitePlyNumber + 1) / 2
      plies: plies

  colorClass: ->
    plyInfo = @currentData()
    _.kebabCase plyInfo.color

  activeClass: ->
    plyInfo = @currentData()
    'active' if plyInfo.ply.number is @chess.gameManager().currentDisplayedPlyNumber()

  endingStatus: ->
    return unless gameState = @chess.gameManager().liveGameState()
    return unless gameState.finished()

    if gameState.checkMate()
      if gameState.turn() is Chess.Piece.Colors.White then '0-1' else '1-0'

    else if gameState.staleMate()
      '½-½'

  moveText: ->
    plyInfo = @currentData()
    ply = plyInfo.ply

    fromSquare = ply.move.from
    toSquare = ply.move.to

    piece = ply.gameState.getPieceAtSquare toSquare
    movingPiece = plyInfo.previousGameState?.getPieceAtSquare fromSquare
    capturedPiece = plyInfo.previousGameState?.getPieceAtSquare toSquare

    if movingPiece.type is Chess.Piece.Types.King and fromSquare.fileIndex is 4 and toSquare.fileIndex in [6, 2]
      moveText = if toSquare.fileIndex is 6 then '0-0' else '0-0-0'

    else
      moveText = @_normalMoveText movingPiece, piece, ply.move, plyInfo.previousGameState, capturedPiece

    if ply.gameState.checkMate()
      moveText += '#'

    else if ply.gameState.check()
      moveText += '+'

    moveText

  _normalMoveText: (movingPiece, piece, move, previousGameState, capturedPiece) ->
    if movingPiece.type is Chess.Piece.Types.Pawn
      moveText = if capturedPiece then move.from.name[0].toLowerCase() else ''

    else
      disambiguationText = @_disambiguationText movingPiece, move, previousGameState
      moveText = "#{movingPiece.letter.toUpperCase()}#{disambiguationText}"

    moveText += 'x' if capturedPiece
    moveText += move.to.name.toLowerCase()
    moveText += @_promotionText movingPiece, piece

    moveText

  _promotionText: (movingPiece, piece) ->
    return '' unless movingPiece.type is Chess.Piece.Types.Pawn
    return '' if piece.type is Chess.Piece.Types.Pawn

    "=#{piece.letter.toUpperCase()}"

  _disambiguationText: (piece, move, previousGameState) ->
    ambiguousFromSquares = for fromSquare in previousGameState.occupiedSquares() when fromSquare isnt move.from
      otherPiece = previousGameState.getPieceAtSquare fromSquare
      continue unless otherPiece.color is piece.color and otherPiece.type is piece.type
      continue unless move.to in previousGameState.getLegalMovesFromSquare fromSquare
      fromSquare

    return '' unless ambiguousFromSquares.length

    sameFile = _.find ambiguousFromSquares, (ambiguousFromSquare) => ambiguousFromSquare.fileIndex is move.from.fileIndex
    sameRank = _.find ambiguousFromSquares, (ambiguousFromSquare) => ambiguousFromSquare.rankIndex is move.from.rankIndex

    fromSquareName = move.from.name.toLowerCase()

    if sameFile and sameRank
      fromSquareName

    else if sameFile
      fromSquareName[1]

    else
      fromSquareName[0]

  events: ->
    super(arguments...).concat
      'click .ply': @onClickPly

  onClickPly: (event) ->
    return unless ply = @currentData()?.ply

    @chess.gameManager().displayPosition ply.number
