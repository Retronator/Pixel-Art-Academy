PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.GameState
  @FileLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  @RankNumbers = [1..8]

  @getSquareName: (fileIndex, rankIndex) -> "#{@FileLetters[fileIndex]}#{@RankNumbers[rankIndex]}"
  
  @getEmptyData: ->
    turn: 'white'
    pieces: {}
    castling: {}
    halfMove: 0
    fullMove: 0

  constructor: (@data) ->

  getPieceAt: (fileIndex, rankIndex) -> Chess.Piece.fromLetter @data.pieces[@constructor.getSquareName fileIndex, rankIndex]

  turn: -> if @data.turn is 'white' then Chess.Piece.Colors.White else Chess.Piece.Colors.Black
  
  finished: -> @data.isFinished
