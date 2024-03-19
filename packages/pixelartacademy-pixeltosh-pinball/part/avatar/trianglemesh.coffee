AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.TriangleMesh extends Pinball.Part.Avatar.Shape
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
