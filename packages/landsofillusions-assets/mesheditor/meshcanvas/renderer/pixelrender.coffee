AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.PixelRender
  constructor: (@renderer) ->
    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene

    @renderTarget = new THREE.WebGLRenderTarget 16, 16,
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    material = new THREE.MeshBasicMaterial
      map: @renderTarget.texture
      depthWrite: false

    geometry = new THREE.PlaneBufferGeometry

    @picture = new THREE.Mesh geometry, material
    scene.add @picture

    @renderer.meshCanvas.autorun (computation) =>
      return unless viewportBounds = @renderer.meshCanvas.pixelCanvas.camera()?.viewportBounds?.toObject()
      return unless viewportBounds.width

      topLeft =
        x: Math.floor viewportBounds.left
        y: Math.floor viewportBounds.top

      bottomRight =
        x: Math.ceil viewportBounds.right
        y: Math.ceil viewportBounds.bottom

      width = bottomRight.x - topLeft.x
      height = bottomRight.y - topLeft.y

      @renderTarget.setSize width, height

      @picture.scale.x = width
      @picture.scale.y = -height
      @picture.scale.z = -1
      @picture.position.x = topLeft.x + width / 2
      @picture.position.y = topLeft.y + height / 2
      @picture.position.z = -1

      @scene.updated()
