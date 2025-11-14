AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Draw.RealisticDrawing extends DrawQuickly.Interface.Game.Draw
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.RealisticDrawing'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @realisticDrawing = @game.drawQuickly.realisticDrawing
    
  onRendered: ->
    super arguments...
    
    @realisticDrawing.start()
  
  onDestroyed: ->
    super arguments...
    
    @realisticDrawing.stop()
    
  showInstructions: ->
    return unless timer = @realisticDrawing.timer()
    timer.time() and not timer.running()
  
  showInstructionsClass: ->
    'show-instructions' if @showInstructions()
    
  roundNumber: -> @realisticDrawing.durationIndex() + 1
  
  referenceUrl: ->
    "/pixelartacademy/pixeltosh/programs/drawquickly/references/#{_.fileCase @realisticDrawing.thingToDraw}.png"
