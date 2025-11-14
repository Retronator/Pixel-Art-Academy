AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Draw.RealisticDrawing.References extends DrawQuickly.Interface.Game.Draw
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.RealisticDrawing.References'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @game = @ancestorComponentOfType DrawQuickly.Interface.Game
    @realisticDrawing = @game.drawQuickly.realisticDrawing
  
  referenceUrl: ->
    "/pixelartacademy/pixeltosh/programs/drawquickly/references/#{@realisticDrawing.thingToDraw}/#{@realisticDrawing.durationIndex() + 1}.png"
    
  durations: ->
    for duration, index in DrawQuickly.RealisticDrawing.durations
      {duration, index}
  
  class @ReferenceTab extends AM.Component
    @register 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.RealisticDrawing.References.ReferenceTab'
    
    onCreated: ->
      super arguments...
      
      @game = @ancestorComponentOfType DrawQuickly.Interface.Game
      @realisticDrawing = @game.drawQuickly.realisticDrawing
    
    activeClass: ->
      durationInfo = @data()
      'active' if durationInfo.index is @realisticDrawing.durationIndex()
      
    completedClass: ->
      durationInfo = @data()
      'completed' if durationInfo.index < @realisticDrawing.completedDurationsCount()
      
    time: ->
      durationInfo = @data()
      DrawQuickly.RealisticDrawing.durations[durationInfo.index]
      
    minutes: ->
      Math.floor Math.ceil(@time()) / 60
    
    seconds: ->
      seconds = Math.ceil(@time()) % 60
      seconds.toString().padStart 2, '0'
