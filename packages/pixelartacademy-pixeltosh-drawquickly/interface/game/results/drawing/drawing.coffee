AM = Artificial.Mirage
AEc = Artificial.Echo
AP = Artificial.Pyramid
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

Bresenham = require('bresenham-zingl')

class DrawQuickly.Interface.Game.Results.Drawing extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Results.Drawing'
  @register @id()
  
  onRendered: ->
    drawing = @data()
    size = drawing.size
    scale = size / 100
    
    canvas = new AM.ReadableCanvas size, size
    imageData = canvas.getFullImageData()
    
    for stroke in drawing.strokes
      for vertexIndex in [0...stroke.length - 1]
        start = stroke[vertexIndex]
        end = stroke[vertexIndex + 1]
        
        startX = Math.round start.x * scale
        startY = Math.round start.y * scale
        endX = Math.round end.x * scale
        endY = Math.round end.y * scale
        
        Bresenham.line startX, startY, endX, endY, (x, y) =>
          imageData.data[(x + y * imageData.width) * 4 + 3] = 255
    
    canvas.putFullImageData imageData
    canvas.classList.add 'canvas'
    @$('.canvas-area').append canvas
  
  canvasAreaStyle: ->
    drawing = @data()
    width: "#{drawing.size}rem"
    height: "#{drawing.size}rem"
