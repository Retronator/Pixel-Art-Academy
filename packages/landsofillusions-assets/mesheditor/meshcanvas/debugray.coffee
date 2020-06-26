LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.DebugRay extends THREE.LineSegments
  constructor: (@meshCanvas) ->
    geometry = new THREE.BufferGeometry

    # We create a line from 0 to 1000 in -Z direction.
    verticesArray = new Float32Array [0, 0, 0, 0, 0, -2]

    geometry.setAttribute 'position', new THREE.BufferAttribute verticesArray, 3
    material = new THREE.LineBasicMaterial color: 0xff0000

    super geometry, material

    @layers.set 2

    @meshCanvas.sceneHelper().scene().add @

  set: (position, direction) ->
    @position.copy position
    @quaternion.setFromUnitVectors new THREE.Vector3(0, 0, -1), direction

    @meshCanvas.sceneHelper().scene.updated()
