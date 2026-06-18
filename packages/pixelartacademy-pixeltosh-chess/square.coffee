PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Square
  @FileLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
  @RankNumbers = [1..8]
  
  @Colors =
    Dark: 'Dark'
    Light: 'Light'

  @getName: (fileIndex, rankIndex) -> "#{@FileLetters[fileIndex]}#{@RankNumbers[rankIndex]}"

  constructor: (@fileIndex, @rankIndex) ->
    @name = @constructor.getName @fileIndex, @rankIndex
    @engineName = @name.toUpperCase()
    @color = if (@fileIndex + @rankIndex) % 2 then @constructor.Colors.Dark else @constructor.Colors.Light
    
  manhattanDistanceTo: (square) ->
    Math.abs(@fileIndex - square.fileIndex) + Math.abs(@rankIndex - square.rankIndex)

for fileIndex in [0...8]
  Chess.Square[fileIndex] = []

  for rankIndex in [0...8]
    square = new Chess.Square fileIndex, rankIndex
    Chess.Square[fileIndex][rankIndex] = square
    Chess.Square[square.name] = square
    Chess.Square[square.engineName] = square
