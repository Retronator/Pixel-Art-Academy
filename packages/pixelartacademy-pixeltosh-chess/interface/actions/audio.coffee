PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.AudioBoard extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.AudioBoard'
  @displayName: -> "Board Sounds"

  @initialize()

  active: -> Chess.audioBoard()

  execute: ->
    Chess.audioBoard not Chess.audioBoard()

class Chess.Interface.Actions.AudioVoice extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.AudioVoice'
  @displayName: -> "Pixeltosh Voice"

  @initialize()

  active: -> Chess.audioVoice()

  execute: ->
    Chess.audioVoice not Chess.audioVoice()
