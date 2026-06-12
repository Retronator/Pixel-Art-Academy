AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.DisplayBoardCoordinates extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.DisplayBoardCoordinates'
  @displayName: -> "Board Coordinates"

  @initialize()
  
  active: ->
    return unless interfaceManager = @chess.interfaceManager()
    interfaceManager.displayBoardCoordinates()
    
  enabled: ->
    return unless interfaceManager = @chess.interfaceManager()
    not interfaceManager.inLesson()
  
  execute: ->
    Chess.displayBoardCoordinates not Chess.displayBoardCoordinates()
