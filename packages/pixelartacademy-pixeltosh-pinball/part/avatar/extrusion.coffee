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
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    lines = []

    for core in @pixelArtEvaluation.layers[0].cores
      for line in core.outlines
        points = @constructor._getLinePoints line
        
        for point in points
          point.x -= @bitmapOrigin.x
          point.x *= -1 if @properties.flipped
          point.y -= @bitmapOrigin.y
          
        lines.push points
    
    @geometryData = @constructor._createExtrudedVerticesAndIndices lines, 0, -@height
    
  collisionShapeMargin: -> null
  
  createPhysicsDebugGeometry: ->
    geometry = new THREE.BufferGeometry
    geometry.setAttribute 'position', new THREE.BufferAttribute @geometryData.vertices, 3
    geometry.setIndex new THREE.BufferAttribute @geometryData.indices, 1
    geometry.computeBoundingBox()
    geometry

  createCollisionShape: ->
    triangleMesh = new Ammo.btTriangleMesh()
    
    vertices = @geometryData.vertices
    indices = @geometryData.indices
    
    for index in [0...indices.length] by 3
      triangleVertices = for vertexIndex in [0..2]
        vertexCoordinateIndex = indices[index + vertexIndex] * 3
        new Ammo.btVector3 vertices[vertexCoordinateIndex], vertices[vertexCoordinateIndex + 1], vertices[vertexCoordinateIndex + 2]
      
      triangleMesh.addTriangle triangleVertices[0], triangleVertices[1], triangleVertices[2]
    
    new Ammo.btBvhTriangleMeshShape triangleMesh

  yPosition: -> @height
