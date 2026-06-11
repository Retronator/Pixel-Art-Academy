AE = Artificial.Everywhere
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class ChessboardTheme extends Chess.Interface.Actions.Action
  @chessboardTheme: -> throw new AE.NotImplementedException "Chessboard theme action must provide the theme it activates."

  active: ->
    return unless interfaceManager = @chess.interfaceManager()
    interfaceManager.chessboardTheme() is @constructor.chessboardTheme()

  execute: ->
    projectId = Chess.currentProjectId()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        chessboardTheme: @constructor.chessboardTheme()
        lastEditTime: new Date

class Chess.Interface.Actions.LightChessboard extends ChessboardTheme
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.LightChessboard'
  @displayName: -> "Light Chessboard"

  @chessboardTheme: -> Chess.ChessboardThemes.Light

  @initialize()

class Chess.Interface.Actions.ContrastChessboard extends ChessboardTheme
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.ContrastChessboard'
  @displayName: -> "Contrast Chessboard"

  @chessboardTheme: -> Chess.ChessboardThemes.Contrast

  @initialize()

class Chess.Interface.Actions.DarkChessboard extends ChessboardTheme
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.DarkChessboard'
  @displayName: -> "Dark Chessboard"

  @chessboardTheme: -> Chess.ChessboardThemes.Dark

  @initialize()
