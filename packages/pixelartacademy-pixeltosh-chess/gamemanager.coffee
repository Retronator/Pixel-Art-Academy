PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.GameManager
  @PiecesInfo:
    Pawn:
      price: 1
      requiredCount: 8
    Knight:
      price: 3
      requiredCount: 2
    Bishop:
      price: 3
      requiredCount: 2
    Rook:
      price: 5
      requiredCount: 2
    Queen:
      price: 9
      requiredCount: 1
    King:
      price: 10
      requiredCount: 1

  constructor: (@chess) ->
    @currency = @chess.state.field 'currency', default: 0
    @ownedPieceTypeCounts = @chess.state.field 'ownedPieceTypeCounts', default: {}
    
    # Give the player the first currency if they have no pieces.
    Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()
      
      @currency 1 unless @ownedPiecesCount() or @currency()
    
  destroy: ->
    
  ownedPiecesCount: (pieceType) ->
    counts = @ownedPieceTypeCounts()

    if pieceType
      counts[pieceType] or 0
      
    else
      _.sum _.values counts
