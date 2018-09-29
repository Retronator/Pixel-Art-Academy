AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.SceneManager
  constructor: (@meshCanvas) ->
    @scene = new AE.ReactiveWrapper null

    # Initialize components.
    scene = new THREE.Scene()
    @scene scene

    ambientLight = new THREE.AmbientLight 0xffffff, 0.4
    scene.add ambientLight

    directionalLight = new THREE.DirectionalLight 0xffffff, 0.6

    directionalLight.castShadow = true
    d = 10
    directionalLight.shadow.camera.left = -d
    directionalLight.shadow.camera.right = d
    directionalLight.shadow.camera.top = d
    directionalLight.shadow.camera.bottom = -d
    directionalLight.shadow.camera.near = 50
    directionalLight.shadow.camera.far = 200
    directionalLight.shadow.mapSize.width = 4096
    directionalLight.shadow.mapSize.height = 4096
    directionalLight.shadow.bias = 0.0001
    
    scene.add directionalLight

    # Move light around
    @meshCanvas.autorun (computation) =>
      directionalLight.position.copy @meshCanvas.options.lightDirection().clone().multiplyScalar -100
      @scene.updated()
