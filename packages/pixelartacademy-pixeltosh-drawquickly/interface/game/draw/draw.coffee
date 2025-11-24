AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Draw extends AM.Component
  constructor: ->
    super arguments...
  
  onCreated: ->
    super arguments...
    
    @game = @ancestorComponentOfType DrawQuickly.Interface.Game
