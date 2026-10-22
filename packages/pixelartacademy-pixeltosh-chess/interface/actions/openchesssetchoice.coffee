PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.OpenChessSetChoice extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.OpenChessSetChoice'
  @displayName: -> "Choose"

  @initialize()

  enabled: -> super(arguments...) and not @chess.interfaceManager()?.choosingChessSet()

  execute: -> @chess.interfaceManager().openChessSetChoice()
