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
    
  showInstructions: ->
    return unless timer = @realisticDrawing.timer()
    timer.time() and not timer.running()
  
  score: ->
    score = @realisticDrawing.score()

    sum = score.symbolic + score.realistic
    return unless sum
    
    proportionalScore = score.realistic / sum
    
    combinedScore = @percentage Math.max score.realistic, proportionalScore
    
    "#{combinedScore} r:#{@percentage score.realistic} s:#{@percentage score.symbolic} p:#{@percentage proportionalScore}"
  
  percentage: (score) ->
    "#{Math.round score * 100}%"
