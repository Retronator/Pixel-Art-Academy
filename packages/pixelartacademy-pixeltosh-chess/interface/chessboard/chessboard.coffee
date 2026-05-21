LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard extends LOI.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @chess = @os.getProgram Chess

    # Create board squares.
    @squares = []

    for fileIndex in [0...8]
      file = []
      @squares.push file

      for rankIndex in [0...8]
        file[rankIndex] = new @constructor.Square fileIndex, rankIndex

  onRendered: ->
    super arguments...

    for rank in [1..8]
      @$('.ranks .border').append("<div class='coordinate'>#{rank}</div>")

    for file in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
      @$('.files .border').append("<div class='coordinate'>#{file}</div>")

  coordinatesVisibleClass: ->
    'visible' if @chess.interfaceManager().displayBoardCoordinates()

  flippedClass: ->
    'flipped' if @chess.interfaceManager().flippedBoard()
