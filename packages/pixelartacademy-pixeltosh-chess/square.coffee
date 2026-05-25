PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Square
  @FileLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  @RankNumbers = [1..8]

  @getName: (fileIndex, rankIndex) -> "#{@FileLetters[fileIndex]}#{@RankNumbers[rankIndex]}"

  constructor: (@fileIndex, @rankIndex) ->
    @name = @constructor.getName @fileIndex, @rankIndex

for fileIndex in [0...8]
  Chess.Square[fileIndex] = []

  for rankIndex in [0...8]
    square = new Chess.Square fileIndex, rankIndex
    Chess.Square[fileIndex][rankIndex] = square
    Chess.Square[square.name] = square
