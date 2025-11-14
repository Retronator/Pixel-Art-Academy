AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Draw.SymbolicDrawing extends DrawQuickly.Interface.Game.Draw
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.SymbolicDrawing'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @symbolicDrawing = @game.drawQuickly.symbolicDrawing
    @symbolicDrawing.reset()
    
  onRendered: ->
    super arguments...
    
    @symbolicDrawing.start()
    
  showInstructions: ->
    not (@symbolicDrawing.thingsDrawn().length or @symbolicDrawing.guessesText().length)
