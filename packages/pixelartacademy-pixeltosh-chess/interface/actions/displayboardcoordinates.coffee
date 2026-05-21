AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.DisplayBoardCoordinates extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.DisplayBoardCoordinates'
  @displayName: -> "Board coordinates"

  @initialize()
  
  active: -> @chess.interfaceManager().displayBoardCoordinates()
  
  execute: ->
    interfaceManager = @chess.interfaceManager()
    interfaceManager.displayBoardCoordinates not interfaceManager.displayBoardCoordinates()
