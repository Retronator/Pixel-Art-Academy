AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.Square extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.Square'
  @register @id()
  
  constructor: (@chessboard, @fileIndex, @rankIndex) ->
    super arguments...

  typeClass: ->
    if (@fileIndex + @rankIndex) % 2 then 'light' else 'dark'

  piece: ->
    @chessboard.chess.gameManager()?.gameState()?.getPieceAt @fileIndex, @rankIndex
