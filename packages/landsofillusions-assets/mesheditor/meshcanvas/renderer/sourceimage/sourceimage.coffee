AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.SourceImage
  constructor: (@renderer) ->
    meshCanvas = @renderer.meshCanvas

    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene

    ambientLight = new THREE.AmbientLight 0xffffff, 0.4
    scene.add ambientLight

    directionalLight = new THREE.DirectionalLight 0xffffff, 0.6
    scene.add directionalLight

    @lightDirectionHelper = meshCanvas.interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @fileId

    # Move light around.
    meshCanvas.autorun (computation) =>
      lightDirection = @lightDirectionHelper()
      directionalLight.position.copy lightDirection.clone().multiplyScalar -100
      @scene.updated()

    material = new @constructor.Material @
    geometry = new THREE.PlaneBufferGeometry
    @image = new THREE.Mesh geometry, material
    scene.add @image

    meshCanvas.autorun (computation) =>
      return unless picture = meshCanvas.activePicture()
      return unless bounds = picture.bounds()

      @image.scale.x = bounds.width
      @image.scale.y = bounds.height
      @image.position.x = bounds.x + bounds.width / 2
      @image.position.y = bounds.y + bounds.height / 2
      @image.position.z = -1

      @scene.updated()
