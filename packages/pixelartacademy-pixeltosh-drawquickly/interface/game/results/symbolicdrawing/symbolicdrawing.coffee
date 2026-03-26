AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Results.SymbolicDrawing extends DrawQuickly.Interface.Game.Results
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Results.SymbolicDrawing'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @symbolicDrawing = @game.drawQuickly.symbolicDrawing
  
  drawings: ->
    {label, strokes, size: 50} for label, strokes of @symbolicDrawing.drawings
