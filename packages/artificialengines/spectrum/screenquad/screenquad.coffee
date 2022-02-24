AS = Artificial.Spectrum

# A unit quad that provides the scene and camera to render it full-screen.
class AS.ScreenQuad extends THREE.Mesh
  constructor: (mapOrMaterial) ->
    if mapOrMaterial.isMaterial
      material = mapOrMaterial
      
    else
      map = mapOrMaterial
      material = new THREE.MeshBasicMaterial {map}
    
    super new THREE.PlaneBufferGeometry(2, 2), material

    @scene = new THREE.Scene
    @scene.add @

    @camera = new THREE.OrthographicCamera -1, 1, 1, -1, 0, 1
