LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup

_normal = new THREE.Vector2

class Markup.EngineComponent
  # The minimum zoom level where markup pixels match display pixels
  # (markup pixels will be scaled down when zoomed out more than this).
  @minimumZoomPercentage = 400 # %
  
  drawMarkup: (markup, context, properties) ->
    # How big is an HTML canvas pixel relative to the unit of the context.
    pixelSize = properties.pixelSize
  
    # How big is a game display pixel relative to the unit of the context.
    displayPixelSize = properties.displayPixelSize
    
    minimumZoomPercentage = properties.minimumZoomPercentage ? @constructor.minimumZoomPercentage
    
    scaledDisplayPixelSize = Math.min 100 / minimumZoomPercentage, displayPixelSize
    
    context.save()
    
    for marking in markup
      if pixel = marking.pixel
        context.fillStyle = pixel.style
        context.fillRect pixel.x, pixel.y, 1, 1
        
      if point = marking.point
        radius = scaledDisplayPixelSize * (point.radius or 0.5)
        context.fillStyle = point.style
        context.beginPath()
        context.arc point.x, point.y, radius, 0, 2 * Math.PI
        context.fill()
      
      if line = marking.line
        context.strokeStyle = line.style
        context.lineCap = line.cap
        context.lineWidth = scaledDisplayPixelSize * (line.width or 1)

        # Allow for 'hairline' width (as small as possible).
        context.lineWidth = pixelSize if line.width is 0
        
        # Allow for width defined in absolute pixel units.
        context.lineWidth = line.absoluteWidth if line.absoluteWidth
        
        context.beginPath()
        
        if line.points
          context.moveTo line.points[0].x, line.points[0].y
          
          for point in line.points[1..]
            if controlPoints = point.bezierControlPoints
              context.bezierCurveTo controlPoints[0].x, controlPoints[0].y, controlPoints[1].x, controlPoints[1].y, point.x, point.y
              
            else
              context.lineTo point.x, point.y
        
          context.stroke()
          
          if line.arrow
            if line.arrow.start
              endPoint = line.points[0]
              
              if line.points[1].bezierControlPoints
                startPoint = line.points[1].bezierControlPoints[0]
              
              else
                startPoint = line.points[1]
                
              @_drawArrow context, startPoint, endPoint, line.arrow.width, line.arrow.length
            
            if line.arrow.end
              endPoint = line.points[line.points.length - 1]
              
              if endPoint.bezierControlPoints
                startPoint = endPoint.bezierControlPoints[1]
                
              else
                startPoint = line.points[line.points.length - 2]
              
              @_drawArrow context, startPoint, endPoint, line.arrow.width, line.arrow.length
            
        if line.arc
          startAngle = line.arc.startAngle or 0
          endAngle = line.arc.endAngle or Math.PI * 2

          context.arc line.arc.x, line.arc.y, line.arc.radius, startAngle, endAngle
          context.stroke()
        
      if rectangle = marking.rectangle
        if rectangle.fillStyle
          context.fillStyle = rectangle.fillStyle
          context.fillRect rectangle.x, rectangle.y, rectangle.width, rectangle.height
        
        if rectangle.strokeStyle
          context.lineWidth = scaledDisplayPixelSize * (rectangle.strokeWidth or 1)
          context.strokeStyle = rectangle.strokeStyle
          
          effectiveLineWidth = context.lineWidth / pixelSize
          sharpPixelOffset = if effectiveLineWidth % 2 is 1 then 0.5 else 0
          
          sharpX = (Math.floor(rectangle.x / pixelSize) + sharpPixelOffset) * pixelSize
          sharpY = (Math.floor(rectangle.y / pixelSize) + sharpPixelOffset) * pixelSize
          
          context.strokeRect sharpX, sharpY, rectangle.width, rectangle.height
          
      if text = marking.text
        textSize = text.size * scaledDisplayPixelSize
        context.font = "#{textSize}px #{text.font}"
        
        if text.backgroundStyle
          context.fillStyle = text.backgroundStyle
          @_drawTextBackground context, text.value, text.position, lineHeight, text.backgroundPadding
        
        if text.lineHeight
          lineHeight = text.lineHeight * scaledDisplayPixelSize
          
        else
          lineHeight = textSize * 1.2
          
        textPosition = _.clone text.position
        
        # Adjust for right-based origin to have an extra pixel space.
        if _.endsWith textPosition.origin, 'Right'
          textPosition.x += scaledDisplayPixelSize
          
        if text.outline
          # Adjust position to accommodate for the outline.
          if _.endsWith textPosition.origin, 'Left'
            textPosition.x += scaledDisplayPixelSize
            
          if _.endsWith textPosition.origin, 'Right'
            textPosition.x -= scaledDisplayPixelSize
          
          if _.startsWith textPosition.origin, 'Top'
            textPosition.y += scaledDisplayPixelSize
          
          if _.startsWith textPosition.origin, 'Bottom'
            textPosition.y -= scaledDisplayPixelSize
          
          context.fillStyle = text.outline.style
          
          outlineWidth = text.outline.width or 1
          outlinePosition = _.clone textPosition
          
          context.beginPath()
          
          for offsetX in [-outlineWidth..outlineWidth]
            for offsetY in [-outlineWidth..outlineWidth] when offsetX or offsetY
              outlinePosition.x = textPosition.x + offsetX * scaledDisplayPixelSize
              outlinePosition.y = textPosition.y + offsetY * scaledDisplayPixelSize
              @_drawText context, text.value, outlinePosition, lineHeight, text.align
              
          context.fill()
        
        context.fillStyle = text.style
        @_drawText context, text.value, textPosition, lineHeight, text.align
      
    context.restore()

  _drawArrow: (context, start, end, width = 1, length = 0.5) ->
    _normal.subVectors end, start
    
    context.save()
    
    context.translate end.x, end.y
    context.rotate _normal.angle() + Math.PI
    
    context.moveTo length, width / 2
    context.lineTo 0, 0
    context.lineTo length, -width / 2
    
    context.stroke()
    
    context.restore()
    
  _drawText: (context, text, position, lineHeight, align) ->
    lines = text.split '\n'

    widths = (context.measureText(line).width for line in lines)
    maxWidth = _.max widths
    
    middleFactor = 0
    context.textBaseline = 'top'
    
    if _.startsWith position.origin, 'Middle'
      middleFactor = 0.5
      context.textBaseline = 'middle'
  
    if _.startsWith position.origin, 'Bottom'
      middleFactor = 1
      context.textBaseline = 'bottom'

    centerFactor = 0
    centerFactor = 0.5 if _.endsWith position.origin, 'Center'
    centerFactor = 1 if _.endsWith position.origin, 'Right'
    
    y = position.y - (lines.length - 1) * lineHeight * middleFactor
    originX = position.x - maxWidth * centerFactor
    
    alignFactor = 0
    alignFactor = 0.5 if align is Markup.TextAlign.Center
    alignFactor = 1 if align is Markup.TextAlign.Right
    
    for line in lines
      width = context.measureText(line).width
      x = originX + (maxWidth - width) * alignFactor
      context.fillText line, x, y
      y += lineHeight
  
  _drawTextBackground: (context, text, position, lineHeight, padding = 0) ->
    lines = text.split '\n'
    
    widths = (context.measureText(line).width for line in lines)

    width = _.max widths
    height = lineHeight * lines.length
    
    verticalFactor = 0
    verticalFactor = 0.5 if _.startsWith position.origin, 'Middle'
    verticalFactor = 1 if _.startsWith position.origin, 'Bottom'
    
    centerFactor = 0
    centerFactor = 0.5 if _.endsWith position.origin, 'Center'
    centerFactor = 1 if _.endsWith position.origin, 'Right'
    
    y = position.y - height * verticalFactor - padding
    x = position.x - width * centerFactor - padding
    
    context.fillRect x, y, width + 2 * padding, height + 2 * padding
