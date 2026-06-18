AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.HistoryBack extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.HistoryBack'
  @displayName: -> "Back in History"

  @initialize()

  enabled: ->
    return unless @chess.interfaceManager()?.inPlay()
    @chess.gameManager().currentDisplayedPlyNumber()

  execute: -> @chess.gameManager().displayPreviousPosition()

class Chess.Interface.Actions.HistoryForward extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.HistoryForward'
  @displayName: -> "Forward in History"

  @initialize()
  
  enabled: ->
    return unless @chess.interfaceManager()?.inPlay()
    not @chess.gameManager().displayingLivePosition()

  execute: -> @chess.gameManager().displayNextPosition()
