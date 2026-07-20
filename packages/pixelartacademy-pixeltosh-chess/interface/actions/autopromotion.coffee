AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Actions.AutoPromotion extends Chess.Interface.Actions.Action
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.AutoPromotion'
  @displayName: -> "Always Promote to Queen"

  @initialize()

  active: ->
    return unless interfaceManager = @chess.interfaceManager()
    interfaceManager.autoPromotion()
  
  enabled: ->
    return unless interfaceManager = @chess.interfaceManager()
    not interfaceManager.inLesson()
    
  execute: ->
    Chess.autoPromotion not Chess.autoPromotion()
