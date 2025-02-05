AC = Artificial.Control
AM = Artificial.Mirage
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Playfield.Grid extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Interface.Playfield.Grid'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @playfield = @ancestorComponentOfType Pinball.Interface.Playfield
    
    @gridCanvas = new AM.Canvas 180, 200
    context = @gridCanvas.context
    
    context.setLineDash [1, 1]
    
    for x in [10..170] by 10
      context.moveTo x + 0.5, 0
      context.lineTo x + 0.5, 200
      
    for y in [10..190] by 10
      context.moveTo 0, y + 0.5
      context.lineTo 180, y + 0.5
      
    context.stroke()
  
  onRendered: ->
    super arguments...
    
    $grid = @$('.pixelartacademy-pixeltosh-programs-pinball-interface-playfield-grid')
    $grid.append @gridCanvas
  
  visibleClass: ->
    'visible' if @playfield.pinball.showGrid()
