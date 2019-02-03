AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.SourceImage
  constructor: (@renderer) ->
    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene
    
    material = new THREE.MeshBasicMaterial color: 0xff0000 # @constructor.Material
    geometry = new THREE.PlaneBufferGeometry
    @image = new THREE.Mesh geometry, material
    scene.add @image

    meshCanvas = @renderer.meshCanvas
    meshCanvas.autorun (computation) =>
      return unless picture = meshCanvas.activePicture()

      bounds = picture.bounds()
      @image.scale.x = bounds.width
      @image.scale.y = -bounds.height
      @image.scale.z = -1
      @image.position.x = bounds.x + bounds.width / 2
      @image.position.y = bounds.y + bounds.height / 2
      @image.position.z = -1

      @scene.updated()
