PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Piece
  @Colors =
    White: 'White'
    Black: 'Black'
    
  @AllColors = _.values @Colors
  
  @Types =
    Pawn: 'Pawn'
    Knight: 'Knight'
    Bishop: 'Bishop'
    Rook: 'Rook'
    Queen: 'Queen'
    King: 'King'
    
  @AllTypes = _.values @Types
    
  @PromotionTypes = [
    @Types.Knight
    @Types.Bishop
    @Types.Rook
    @Types.Queen
  ]
  
  @TypeLetters =
    Pawn: 'p'
    Knight: 'n'
    Bishop: 'b'
    Rook: 'r'
    Queen: 'q'
    King: 'k'
  
  @TypesForLetter =
    p: @Types.Pawn
    n: @Types.Knight
    b: @Types.Bishop
    r: @Types.Rook
    q: @Types.Queen
    k: @Types.King
    
  @InfoForType =
    Pawn:
      value: 1
      requiredCount: 8
    Knight:
      value: 3
      requiredCount: 2
    Bishop:
      value: 3
      requiredCount: 2
    Rook:
      value: 5
      requiredCount: 2
    Queen:
      value: 9
      requiredCount: 1
    King:
      value: 10
      requiredCount: 1
  
  @fromLetter: (letter) ->
    return null unless letter
    lowerCaseLetter = letter.toLowerCase()
    
    color = if letter is lowerCaseLetter then @Colors.Black else @Colors.White
    type = @TypesForLetter[lowerCaseLetter]
 
    new @ color, type
    
  @getLetter: (color, type) ->
    letter = @TypeLetters[type]
    letter = letter.toUpperCase() if color is @Colors.White
    letter
    
  constructor: (@color, @type) ->
    @letter = @constructor.getLetter @color, @type
