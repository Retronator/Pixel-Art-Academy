AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.FlipBoard extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.FlipBoard'
  @displayName: -> "Flip board"

  @initialize()

  execute: ->
    interfaceManager = @chess.interfaceManager()
    interfaceManager.flippedBoard not interfaceManager.flippedBoard()
