AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.PixelRender
  constructor: (@renderer) ->
    scene = new THREE.Scene()
    @scene = new AE.ReactiveWrapper scene

    @renderTarget = new THREE.WebGLRenderTarget 1, 1,
      type: THREE.FloatType
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    material = new THREE.MeshBasicMaterial
      transparent: true
      map: @renderTarget.texture
      depthWrite: false

    geometry = new THREE.PlaneBufferGeometry

    @picture = new THREE.Mesh geometry, material
    scene.add @picture

    @bounds = new AE.Rectangle

    @renderer.meshCanvas.autorun (computation) =>
      return unless viewportBounds = @renderer.meshCanvas.pixelCanvas.camera()?.viewportBounds.toObject()
      return unless viewportBounds.width

      Tracker.nonreactive =>
        dimensions =
          top: Math.floor viewportBounds.top
          left: Math.floor viewportBounds.left
          bottom: Math.ceil viewportBounds.bottom
          right: Math.ceil viewportBounds.right

        @bounds.fromDimensions dimensions

        @renderTarget.setSize @bounds.width(), @bounds.height()
        center = @bounds.center()

        @picture.scale.x = @bounds.width()
        @picture.scale.y = -@bounds.height()
        @picture.scale.z = -1
        @picture.position.x = center.x
        @picture.position.y = center.y
        @picture.position.z = -1

        console.log "Pixel render updated", viewportBounds, @bounds.toObject(), @picture.scale, @picture.position if LOI.Assets.debug

        @scene.updated()
