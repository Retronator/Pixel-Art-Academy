AC = Artificial.Control
AM = Artificial.Mirage
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Parts extends Pinball.Interface.Parts
  @register @id()
  
  @polygonDebug = false

  @debugPlayfieldTriangulation = false
  @debugWallsTriangulation = false
  @debugExtrusionLines = false
  
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
          indexBufferArray = wallsPolygon.triangulate()
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

      if @constructor.debugExtrusionLines
        scale = @polygonDebugCanvas.width / 180
        curvePointsCount = Pinball.Part.Avatar.Shape.curveExtraPointsCount + 1

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
          
          for line in shape.pixelArtEvaluation.layers[0].lines
            for linePart in line.parts
              if linePart instanceof PAE.Line.Part.StraightLine
                drawPolygon 'gold', 4, vertices: [
                    linePart.displayLine2.start
                    linePart.displayLine2.end
                  ]
                  
              if linePart instanceof PAE.Line.Part.Curve
                previousPoint = linePart.displayPoints[0]
                vertices = [
                  previousPoint.position
                ]
                
                for point in linePart.displayPoints[1...]
                  for curvePointIndex in [1..curvePointsCount]
                    vertices.push AP.BezierCurve.getPointOnCubicBezierCurve previousPoint.position, previousPoint.controlPoints.after, point.controlPoints.before, point.position, curvePointIndex / curvePointsCount

                  previousPoint = point
                  
                drawPolygon 'limegreen', 4, {vertices}
  
  onDestroyed: ->
    super arguments...
    
    return unless @constructor.polygonDebug

    $(document).off '.pixelartacademy-pixeltosh-programs-pinball-interface-parts'
