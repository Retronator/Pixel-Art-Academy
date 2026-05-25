PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Move
  @fromEngine: (engineMove) ->
    for fromSquareName, toSquareName of engineMove
      return new @ Chess.Square[fromSquareName], Chess.Square[toSquareName]

  constructor: (@from, @to) ->
