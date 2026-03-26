AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Interface.Game.Complexity extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Complexity'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @drawQuickly = @os.getProgram DrawQuickly
    @game = @parentComponent()
  
  complexityOptions: -> _.values DrawQuickly.RealisticDrawing.ComplexityProperties
    
  imageUrl: ->
    complexity = @currentData()
    
    "/pixelartacademy/pixeltosh/programs/drawquickly/complexity-#{complexity}.png"
  
  completedCount: ->
    complexity = @currentData()
    
    DrawQuickly.RealisticDrawing.getDrawnThingsForComplexity(complexity).length
    
  allCount: ->
    complexity = @currentData()
    DrawQuickly.RealisticDrawing.thingsByComplexity[complexity].length
  
  events: ->
    super(arguments...).concat
      'click .complexity-button': @onClickComplexityButton
  
  onClickComplexityButton: (event) ->
    complexity = @currentData()
    @game.drawQuickly.realisticDrawing.setComplexity complexity
    
    @game.chooseThing()
