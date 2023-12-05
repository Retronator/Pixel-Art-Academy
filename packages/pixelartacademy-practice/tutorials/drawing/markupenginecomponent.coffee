PAA = PixelArtAcademy
LOI = LandsOfIllusions

_normal = new THREE.Vector2

class PAA.Practice.Tutorials.Drawing.MarkupEngineComponent
  @TextOriginPosition =
    TopLeft: 'TopLeft'
    TopCenter: 'TopCenter'
    TopRight: 'TopRight'
    MiddleLeft: 'MiddleLeft'
    MiddleCenter: 'MiddleCenter'
    MiddleRight: 'MiddleRight'
    BottomLeft: 'BottomLeft'
    BottomCenter: 'BottomCenter'
    BottomRight: 'BottomRight'
    
  @TextAlign =
    Left: 'Left'
    Center: 'Center'
    Right: 'Right'
  
  constructor: ->
    @markup = new ComputedField =>
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      return unless instructions = pixelPad.os.getSystem PAA.PixelPad.Systems.Instructions
      return unless instruction = instructions.displayedInstruction()
      instruction.markup?()

  drawToContext: (context, renderOptions = {}) ->
    return unless markup = @markup()
    
    pixelSize = 1 / renderOptions.camera.effectiveScale()
    displayScale = renderOptions.editor.display.scale()
    displayPixelSize = pixelSize * displayScale
    
    scaledDisplayPixelSize = Math.min 1 / 8, displayPixelSize
    
    context.save()
    
    for element in markup
      if pixel = element.pixel
        context.fillStyle = pixel.style
        context.fillRect pixel.x, pixel.y, 1, 1
      
      if line = element.line
        context.strokeStyle = line.style
        context.lineWidth = scaledDisplayPixelSize
        
        context.beginPath()
      
        context.moveTo line.points[0].x, line.points[0].y
        
        for point in line.points[1..]
          if controlPoints = point.bezierControlPoints
            context.bezierCurveTo controlPoints[0].x, controlPoints[0].y, controlPoints[1].x, controlPoints[1].y, point.x, point.y
            
          else
            context.lineTo point.x, point.y
      
        context.stroke()
        
        if line.arrow
          if line.arrow.end
            endPoint = line.points[line.points.length - 1]
            
            if endPoint.bezierControlPoints
              startPoint = endPoint.bezierControlPoints[1]
              
            else
              startPoint = line.points[line.points.length - 2]
              
            @_drawArrow context, startPoint, endPoint
        
      if text = element.text
        context.fillStyle = text.style
        textSize = text.size * scaledDisplayPixelSize
        context.font = "#{textSize}px #{text.font}"
        
        if text.lineHeight
          lineHeight = text.lineHeight * scaledDisplayPixelSize
          
        else
          lineHeight = textSize * 1.2

        @_drawText context, text.value, text.position, lineHeight, text.align
      
    context.restore()

  _drawArrow: (context, start, end, length) ->
    _normal.subVectors end, start
    
    context.save()
    
    context.translate end.x, end.y
    context.rotate _normal.angle() + Math.PI
    
    length = 0.5
    
    context.moveTo length, length
    context.lineTo 0, 0
    context.lineTo length, -length
    
    context.stroke()
    
    context.restore()
    
  _drawText: (context, text, position, lineHeight, align) ->
    lines = text.split '\n'

    widths = (context.measureText(line).width for line in lines)
    maxWidth = _.max widths
    
    middleFactor = 0
    middleFactor = 0.5 if _.startsWith position.origin, 'Middle'
    middleFactor = 1 if _.startsWith position.origin, 'Bottom'

    centerFactor = 0
    centerFactor = 0.5 if _.endsWith position.origin, 'Center'
    centerFactor = 1 if _.endsWith position.origin, 'Right'
    
    y = position.y - (lines.length - 1) * lineHeight * middleFactor
    originX = position.x - maxWidth * centerFactor
    
    alignFactor = 0
    alignFactor = 0.5 if align is @constructor.TextAlign.Center
    alignFactor = 1 if align is @constructor.TextAlign.Right
    
    for line in lines
      width = context.measureText(line).width
      x = originX + (maxWidth - width) * alignFactor
      context.fillText line, x, y
      y += lineHeight
