AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection.CustomComponent.IconCanvas extends LOI.Component
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection.CustomComponent.IconCanvas'
  @register @id()
  
  @pixelScaleForSize =
    8: 5
    16: 2
    32: 1
    
  @gridOpacityForSize =
    8: 1
    16: 0.5
    32: 0
  
  constructor: (@size) ->
    super arguments...
    
  onRendered: ->
    super arguments...
    
    $canvas = @$('.canvas')
    canvas = $canvas[0]
    context = canvas.getContext '2d'
    
    iconPixelScale = @constructor.pixelScaleForSize[@size]
    displaySize = @size * iconPixelScale
    
    gridOpacity = @constructor.gridOpacityForSize[@size]
    
    # Redraw the canvas.
    @autorun (computation) =>
      canvasPixelSize = displaySize
      canvas.width = canvasPixelSize
      canvas.height = canvasPixelSize
      
      if gridOpacity
        context.strokeStyle = "rgba(202, 202, 202, #{gridOpacity})"
        context.beginPath()
  
        for gridlineNumber in [1..@size]
          offset = gridlineNumber * iconPixelScale - 0.5
  
          context.moveTo offset, 0
          context.lineTo offset, canvasPixelSize
          
          context.moveTo 0, offset
          context.lineTo canvasPixelSize, offset
        
        context.stroke()
