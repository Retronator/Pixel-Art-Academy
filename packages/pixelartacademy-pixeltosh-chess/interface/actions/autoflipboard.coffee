AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.AutoFlipBoard extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.AutoFlipBoard'
  @displayName: -> "Automatically Flip Board"

  @initialize()

  active: -> Chess.autoFlipBoard()

  execute: ->
    Chess.autoFlipBoard not Chess.autoFlipBoard()
