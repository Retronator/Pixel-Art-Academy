AC = Artificial.Control
AM = Artificial.Mirage
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Playfield extends Pinball.Interface.Playfield
  @register @id()
  
  @polygonDebug = false

  @debugPlayfieldTriangulation = false
  @debugWallsTriangulation = false
  @debugExtrusionLines = false
  @debugBumper = false
  @debugWireBallGuideLines = false
  
  onCreated: ->
    super arguments...
    
    return unless @constructor.polygonDebug

    @polygonDebugCanvas = new AM.Canvas
    @polygonDebugTrianglesDrawCount = new ReactiveField -1
    
    $(document).on 'keydown.pixelartacademy-pixeltosh-programs-pinball-interface-parts', (event) =>
      switch event.which
        when AC.Keys.period then delta = 1
        when AC.Keys.comma then delta = -1
      
      return unless delta
      
      @polygonDebugTrianglesDrawCount @polygonDebugTrianglesDrawCount() + delta
  
  onRendered: ->
    super arguments...
    
    return unless @constructor.polygonDebug
    
    $polygonDebug = @$('.polygon-debug')
    $polygonDebug.append @polygonDebugCanvas
    
    context = @polygonDebugCanvas.context
    
    @autorun =>
      @pinball.os.display.scale()
      
      @polygonDebugCanvas.width = $polygonDebug.width() * devicePixelRatio
      @polygonDebugCanvas.height = $polygonDebug.height() * devicePixelRatio
      
      parts = @pinball.sceneManager().parts()
      
      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, @polygonDebugCanvas.width, @polygonDebugCanvas.height
      
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      scale = 1
    
      drawPolygon = (style, lineWidth, polygon, closed) =>
        context.strokeStyle = style
        context.lineWidth = lineWidth / scale
        
        context.beginPath()
        
        if closed
          startVertex = _.last polygon.vertices
          
        else
          startVertex = polygon.vertices[0]

        context.moveTo startVertex.x, startVertex.y
        
        for vertex in polygon.vertices
          context.lineTo vertex.x, vertex.y
          
        context.stroke()
        
      drawPoint = (point, radius, style) =>
        context.beginPath()
        context.arc point.x, point.y, radius, 0, 2 * Math.PI
        context.fillStyle = style
        context.fill()
        
      if @constructor.debugPlayfieldTriangulation
        scale = @polygonDebugCanvas.width / 0.53
        context.setTransform 1, 0, 0, 1, 0, 0
        context.scale scale, scale
        context.translate 0.015, 0.015
      
        return unless playfield = _.find parts, (part) => part instanceof Pinball.Parts.Playfield
        
        holeBoundaries = []
        
        for part in parts
          holeBoundaries.push partHoleBoundaries... if partHoleBoundaries = part.playfieldHoleBoundaries()
  
        for holeBoundary in holeBoundaries
          drawPolygon 'yellow', 8, holeBoundary, true
          
        return unless playfield.avatar.shape()
        return unless playfieldBoundary = playfield.avatar.playfieldBoundingRectangle()?.getBoundary()
        
        playfieldPolygon = new AP.PolygonWithHoles playfieldBoundary, holeBoundaries
        playfieldPolygon = playfieldPolygon.getPolygonWithoutHoles()
        
        insetPolygonBoundary = playfieldPolygon.boundary.getInsetPolygonBoundary 0.002
        
        drawPolygon 'blue', 2, insetPolygonBoundary, true
        
        indexBufferArray = playfieldPolygon.triangulate()
        
        trianglesDrawCount = @polygonDebugTrianglesDrawCount()
        
        for indexOfIndex in [0...indexBufferArray.length] by 3
          break unless trianglesDrawCount
          trianglesDrawCount--
  
          drawPolygon 'green', 1, vertices: [
            insetPolygonBoundary.vertices[indexBufferArray[indexOfIndex]]
            insetPolygonBoundary.vertices[indexBufferArray[indexOfIndex + 1]]
            insetPolygonBoundary.vertices[indexBufferArray[indexOfIndex + 2]]
          ], true
          
      if @constructor.debugWallsTriangulation
        return unless walls = _.find parts, (part) => part instanceof Pinball.Parts.Walls
        return unless shape = walls.avatar.shape()
        
        scale = @polygonDebugCanvas.width / 180
        context.setTransform 1, 0, 0, 1, 0, 0
        context.scale scale, scale
        position = walls.position()
        context.translate position.x / pixelSize, position.z / pixelSize
        
        for boundary in shape.boundaries
          wallsPolygon = new AP.Polygon boundary
          indexBufferArray = wallsPolygon.triangulate true
          color = if indexBufferArray.error then 'red' else 'blue'

          drawPolygon color, 8, boundary, true

          trianglesDrawCount = @polygonDebugTrianglesDrawCount()
          
          for indexOfIndex in [0...indexBufferArray.length] by 3
            break unless trianglesDrawCount
            trianglesDrawCount--
    
            drawPolygon 'gray', 1, vertices: [
              wallsPolygon.vertices[indexBufferArray[indexOfIndex]]
              wallsPolygon.vertices[indexBufferArray[indexOfIndex + 1]]
              wallsPolygon.vertices[indexBufferArray[indexOfIndex + 2]]
            ], true
        
      curvePointsCount = Pinball.Part.Avatar.Shape.curveExtraPointsCount + 1
      
      drawLine = (line) =>
        for linePart in line.parts
          if linePart instanceof PAE.Line.Part.StraightLine
            drawPolygon 'gold', 4, vertices: [
              linePart.displayLine2.start
              linePart.displayLine2.end
            ]
          
          if linePart instanceof PAE.Line.Part.Curve
            points = linePart.displayPoints
            
            for point in points
              drawPoint point, 0.5, 'limegreen'

            previousPoint = points[0]
            vertices = [
              previousPoint.position
            ]
            
            endPointIndex = points.length - if linePart.isClosed then 0 else 1
            
            for pointIndex in [1..endPointIndex]
              point = points[_.modulo pointIndex, points.length]
              for curvePointIndex in [1..curvePointsCount]
                vertices.push AP.BezierCurve.getPointOnCubicBezierCurve previousPoint.position, previousPoint.controlPoints.after, point.controlPoints.before, point.position, curvePointIndex / curvePointsCount
              
              previousPoint = point
            
            drawPolygon 'limegreen', 4, {vertices}
            
      if @constructor.debugExtrusionLines
        scale = @polygonDebugCanvas.width / 180

        for part in parts
          continue unless shape = part.shape()
          continue unless shape instanceof Pinball.Part.Avatar.Extrusion
          
          context.setTransform 1, 0, 0, 1, 0, 0
          context.scale scale, scale
          position = part.position()
          context.translate position.x / pixelSize, position.z / pixelSize
          
          if shape.properties.flipped
            context.scale -1, 1
            
          context.translate -shape.bitmapOrigin.x + 0.5, -shape.bitmapOrigin.y + 0.5
          
          drawLine line for line in shape.pixelArtEvaluation.layers[0].lines
      
      if @constructor.debugBumper
        return unless bumper = _.find parts, (part) => part instanceof Pinball.Parts.Bumper
        return unless shape = bumper.ringShape()
        
        displayWidth = shape.bitmapRectangle.width() * 1.2
        displayHeight = displayWidth / 180 * 200
        scale = @polygonDebugCanvas.width / displayWidth
      
        context.setTransform 1, 0, 0, 1, 0, 0
        context.scale scale, scale
        
        if shape.properties.flipped
          context.scale -1, 1

        context.translate displayWidth / 2, displayHeight / 2
        
        for boundary, boundaryIndex in shape.boundaries
          drawPolygon 'green', 8, boundary, true

          taperedBoundary = shape.taperedBoundaries[boundaryIndex]
          
          context.strokeStyle = 'purple'
          context.lineWidth = 4 / scale
          
          context.beginPath()

          for vertex, vertexIndex in boundary.vertices
            taperedVertex = taperedBoundary.vertices[vertexIndex]
            
            context.moveTo vertex.x, vertex.y
            context.lineTo taperedVertex.x, taperedVertex.y
          
          context.stroke()

        for boundary in shape.taperedBoundaries
          taperedPolygon = new AP.Polygon boundary
          indexBufferArray = taperedPolygon.triangulate true
          color = if indexBufferArray.error then 'red' else 'blue'
          
          drawPolygon color, 8, boundary, true
          
          trianglesDrawCount = @polygonDebugTrianglesDrawCount()
          
          for indexOfIndex in [0...indexBufferArray.length] by 3
            break unless trianglesDrawCount
            trianglesDrawCount--
            
            drawPolygon 'gray', 1, vertices: [
              taperedPolygon.vertices[indexBufferArray[indexOfIndex]]
              taperedPolygon.vertices[indexBufferArray[indexOfIndex + 1]]
              taperedPolygon.vertices[indexBufferArray[indexOfIndex + 2]]
            ], true
            
        context.translate -shape.bitmapOrigin.x + 0.5, -shape.bitmapOrigin.y + 0.5
        drawLine line for line in shape.pixelArtEvaluation.layers[0].lines
        
      if @constructor.debugWireBallGuideLines
        return unless wireBallGuides = _.find parts, (part) => part instanceof Pinball.Parts.WireBallGuides
        return unless shape = wireBallGuides.avatar.shape()
        
        scale = @polygonDebugCanvas.width / 180
        curvePointsCount = Pinball.Part.Avatar.Shape.curveExtraPointsCount + 1
        
        context.setTransform 1, 0, 0, 1, 0, 0
        context.scale scale, scale
        position = wireBallGuides.position()
        context.translate position.x / pixelSize, position.z / pixelSize
        context.translate -shape.bitmapOrigin.x + 0.5, -shape.bitmapOrigin.y + 0.5
        
        drawLine line for line in shape.pixelArtEvaluation.layers[0].lines when not line.core
  
  onDestroyed: ->
    super arguments...
    
    return unless @constructor.polygonDebug

    $(document).off '.pixelartacademy-pixeltosh-programs-pinball-interface-parts'
