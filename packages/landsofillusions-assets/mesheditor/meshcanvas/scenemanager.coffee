AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.SceneManager
  constructor: (@meshCanvas) ->
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

    # Move light around.
    @meshCanvas.autorun (computation) =>
      directionalLight.position.copy @meshCanvas.options.lightDirection().clone().multiplyScalar -100
      @scene.updated()

    # Picture scene.
    pictureScene = new THREE.Scene()
    @pictureScene = new AE.ReactiveWrapper pictureScene

    @pictureRenderTarget = new THREE.WebGLRenderTarget 16, 16,
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    pictureMaterial = new THREE.MeshBasicMaterial
      map: @pictureRenderTarget.texture
      depthWrite: false
      
    pictureGeometry = new THREE.PlaneBufferGeometry

    @picture = new THREE.Mesh pictureGeometry, pictureMaterial
    pictureScene.add @picture

    # Position picture to match source image.
    @meshCanvas.autorun (computation) =>
      return unless viewportBounds = @meshCanvas.options.pixelCanvas()?.camera()?.viewportBounds?.toObject()
      return unless viewportBounds.width
      return unless cameraAngle = @meshCanvas.options.cameraAngle()

      topLeft =
        x: Math.floor viewportBounds.left
        y: Math.floor viewportBounds.top

      bottomRight =
        x: Math.ceil viewportBounds.right
        y: Math.ceil viewportBounds.bottom

      width = bottomRight.x - topLeft.x
      height = bottomRight.y - topLeft.y

      @pictureRenderTarget.setSize width, height

      @picture.scale.x = width
      @picture.scale.y = -height
      @picture.scale.z = -1
      @picture.position.x = topLeft.x + width / 2
      @picture.position.y = topLeft.y + height / 2
      @picture.position.z = -1

      @pictureScene.updated()
