AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.Scene extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.Scene'
  @initialize()

  constructor: ->
    super arguments...

    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene

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
    directionalLight.shadow.bias = -0.0001
    
    scene.add directionalLight

    @lightDirectionHelper = @interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @fileId

    # Move light around.
    @autorun (computation) =>
      lightDirection = @lightDirectionHelper()
      directionalLight.position.copy lightDirection.clone().multiplyScalar -100
      @scene.updated()

    # Add the character to the scene once we get the loader.
    @autorun (computation) =>
      return unless meshLoader = @interface.getLoaderForFile @fileId
      computation.stop()

      character = meshLoader.character.instance.avatar.getRenderObject()
      scene.add character
      @scene.updated()
