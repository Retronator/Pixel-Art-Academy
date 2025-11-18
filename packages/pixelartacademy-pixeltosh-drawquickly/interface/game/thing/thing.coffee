AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Thing extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Thing'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @drawQuickly = @os.getProgram DrawQuickly
    @game = @parentComponent()
    
  things: ->
    DrawQuickly.RealisticDrawing.thingsByComplexity[@drawQuickly.realisticDrawing.complexity]
  
  completedThing: ->
    thing = @currentData()
    realisticDrawingData = PAA.Pixeltosh.Programs.DrawQuickly.state 'realisticDrawing'
    
    realisticDrawingData.things[thing]
  
  completedClass: ->
    'completed' if @completedThing()
  
  events: ->
    super(arguments...).concat
      'click .thing-button': @onClickThingButton
      
  onClickThingButton: (event) ->
    thing = @currentData()
    @drawQuickly.realisticDrawing.setThingToDraw thing
    
    if @completedThing()
      @game.showResults()
      
    else
      @game.showInstructions()
