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
    
    canvas = new AM.ReadableCanvas 50, 50
    imageData = canvas.getFullImageData()
    imageData.data.fill 255
    
    for stroke in drawing.strokes
      for vertexIndex in [0...stroke.length - 1]
        start = stroke[vertexIndex]
        end = stroke[vertexIndex + 1]
        
        startX = Math.round start.x / 2
        startY = Math.round start.y / 2
        endX = Math.round end.x / 2
        endY = Math.round end.y / 2
        
        Bresenham.line startX, startY, endX, endY, (x, y) =>
          for channelIndex in [0...3]
            imageData.data[(x + y * imageData.width) * 4 + channelIndex] = 0
    
    canvas.putFullImageData imageData
    canvas.classList.add 'canvas'
    @$('.canvas-area').append canvas
