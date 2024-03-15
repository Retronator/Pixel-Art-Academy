AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Extrusion extends Pinball.Part.Avatar.Shape
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation.layers[0].cores, properties

  constructor: (@cores, @properties) ->
    super arguments...
    
    @bitmapOrigin = x: 0, y: 0

    lines = []
    pointsCount = 0

    for core in @cores
      for line in core.outlines
        points = []
        
        for part in line.parts
          if part instanceof PAE.Line.Part.StraightLine
            points.push part.displayLine2.start unless points.length
            points.push part.displayLine2.end
          
          if part instanceof PAE.Line.Part.Curve
            points.push part.displayPoints[0].position unless points.length
            
            for point in part.displayPoints[1..]
              points.push point.position
        
        lines.push points
        pointsCount += points.length
    
    @vertices = new Float32Array pointsCount * 6
    @indices = new Uint32Array pointsCount * 6
    
    lineStartVertexIndex = 0
    currentIndex = 0
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for line in lines
      bottomVertexIndex = lineStartVertexIndex
      topVertexIndex = bottomVertexIndex + 1
      
      for point, pointIndex in line
        x = (point.x + 0.5) * pixelSize
        y = (point.y + 0.5) * pixelSize
        @vertices[bottomVertexIndex * 3] = x
        @vertices[bottomVertexIndex * 3 + 2] = y
        @vertices[topVertexIndex * 3] = x
        @vertices[topVertexIndex * 3 + 1] = -@properties.height
        @vertices[topVertexIndex * 3 + 2] = y
        
        nextBottomVertexIndex = if pointIndex is line.length - 1 then lineStartVertexIndex else bottomVertexIndex + 2
        nextTopVertexIndex = nextBottomVertexIndex + 1
        
        @indices[currentIndex] = nextBottomVertexIndex
        @indices[currentIndex + 1] = bottomVertexIndex
        @indices[currentIndex + 2] = nextTopVertexIndex
        @indices[currentIndex + 3] = topVertexIndex
        @indices[currentIndex + 4] = nextTopVertexIndex
        @indices[currentIndex + 5] = bottomVertexIndex
        
        bottomVertexIndex += 2
        topVertexIndex += 2
        currentIndex += 6
      
      lineStartVertexIndex += line.length * 2

  createPhysicsDebugGeometry: ->
    geometry = new THREE.BufferGeometry
    geometry.setAttribute 'position', new THREE.BufferAttribute @vertices, 3
    geometry.setIndex new THREE.BufferAttribute @indices, 1
    geometry.computeBoundingBox()
    geometry

  createCollisionShape: ->
    triangleMesh = new Ammo.btTriangleMesh()
    
    for index in [0...@indices.length] by 3
      vertices = for vertexIndex in [0..2]
        vertexCoordinateIndex = @indices[index + vertexIndex] * 3
        new Ammo.btVector3 @vertices[vertexCoordinateIndex], @vertices[vertexCoordinateIndex + 1], @vertices[vertexCoordinateIndex + 2]
      
      triangleMesh.addTriangle vertices[0], vertices[1], vertices[2]
    
    new Ammo.btBvhTriangleMeshShape triangleMesh

  yPosition: -> @properties.height
