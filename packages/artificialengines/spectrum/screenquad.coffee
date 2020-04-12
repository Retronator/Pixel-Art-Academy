AS = Artificial.Spectrum

# A unit quad that provides the scene and camera to render it full-screen.
class AS.ScreenQuad extends THREE.Mesh
  constructor: (map) ->
    super new THREE.PlaneBufferGeometry(2, 2), new THREE.MeshBasicMaterial {map}

    @scene = new THREE.Scene
    @scene.add @

    @camera = new THREE.OrthographicCamera -1, 1, 1, -1, 0.5, 1.5
    @camera.position.z = 1
