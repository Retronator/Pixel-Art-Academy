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
    geometry.setAttribute 'position', new THREE.BufferAttribute @geometryData.vertexBufferArray, 3
    geometry.setIndex new THREE.BufferAttribute @geometryData.indexBufferArray, 1
    geometry.computeBoundingBox()
    geometry

  createCollisionShape: ->
    triangleMesh = new Ammo.btTriangleMesh()
    
    vertexBufferArray = @geometryData.vertexBufferArray
    indexBufferArray = @geometryData.indexBufferArray
    
    for index in [0...indexBufferArray.length] by 3
      triangleVertices = for vertexIndex in [0..2]
        vertexCoordinateIndex = indexBufferArray[index + vertexIndex] * 3
        new Ammo.btVector3 vertexBufferArray[vertexCoordinateIndex], vertexBufferArray[vertexCoordinateIndex + 1], vertexBufferArray[vertexCoordinateIndex + 2]
      
      triangleMesh.addTriangle triangleVertices[0], triangleVertices[1], triangleVertices[2]
    
    new Ammo.btBvhTriangleMeshShape triangleMesh
