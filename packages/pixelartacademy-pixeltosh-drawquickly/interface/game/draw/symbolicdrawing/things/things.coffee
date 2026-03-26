AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Draw.SymbolicDrawing.Things extends DrawQuickly.Interface.Game.Draw
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.SymbolicDrawing.Things'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @game = @ancestorComponentOfType DrawQuickly.Interface.Game
    @symbolicDrawing = @game.drawQuickly.symbolicDrawing
  
  class @Thing extends AM.Component
    @register 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.SymbolicDrawing.Things.Thing'
    
    onCreated: ->
      super arguments...
      
      @game = @ancestorComponentOfType DrawQuickly.Interface.Game
      @symbolicDrawing = @game.drawQuickly.symbolicDrawing
      
    drawnClass: ->
      thingToDraw = @data()
      thingsDrawn = @symbolicDrawing.thingsDrawn()
      'drawn' if thingToDraw in thingsDrawn
