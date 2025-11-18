AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Results.RealisticDrawing extends DrawQuickly.Interface.Game.Results
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Results.RealisticDrawing'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @realisticDrawing = @game.drawQuickly.realisticDrawing
  
  durations: ->
    realisticDrawingData = PAA.Pixeltosh.Programs.DrawQuickly.state 'realisticDrawing'
    
    {duration, index} for duration, index in realisticDrawingData.things[@realisticDrawing.thingToDraw].durations
  
  drawingInfo: ->
    durationInfo = @currentData()
    
    time = DrawQuickly.RealisticDrawing.durationsPerComplexity[@realisticDrawing.complexity][durationInfo.index]
    
    minutes = Math.floor Math.ceil(time) / 60
    seconds = Math.ceil(time) % 60
    
    drawing = DrawQuickly.Drawing.documents.findOne durationInfo.duration.drawingId
    
    strokes: drawing.strokes
    label: "#{minutes}:#{seconds.toString().padStart 2, '0'}"
    size: 80
    
  events: ->
    super(arguments...).concat
      'click .thing-button': @onClickThingButton
  
  onClickThingButton: (event) ->
    @game.chooseThing()
