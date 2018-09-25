AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.CameraManager
  constructor: (@meshCanvas, @options = {}) ->
    camera = new THREE.Camera
    @camera = new AE.ReactiveWrapper camera

    @meshCanvas.autorun (computation) =>
      return unless cameraAngle = @meshCanvas.options.cameraAngle()

      createVector = (vectorData = {}) => new THREE.Vector3 vectorData.x or 0, vectorData.y or 0, vectorData.z or 0

      position = createVector cameraAngle.position
      target = createVector cameraAngle.target
      up = createVector cameraAngle.up

      camera.matrix.lookAt position, target, up
      camera.matrix.setPosition position
      camera.matrix.decompose camera.position, camera.quaternion, camera.scale

      @camera.updated()

    @meshCanvas.autorun (computation) =>
      return unless viewportBounds = @meshCanvas.options.pixelCanvas()?.camera()?.viewportBounds
      return unless cameraAngle = @meshCanvas.options.cameraAngle()
      return unless pixelSize = cameraAngle.pixelSize

      # Note: We offset bounds by half a pixel because we want to look at the center of the pixel.
      left = (viewportBounds.left() - 0.5) * pixelSize
      right = (viewportBounds.right() - 0.5) * pixelSize
      top = (viewportBounds.top() - 0.5) * pixelSize
      bottom = (viewportBounds.bottom() - 0.5) * pixelSize

      if picturePlaneDistance = cameraAngle.picturePlaneDistance
        # We have a perspective projection.
        near = picturePlaneDistance * pixelSize
        far = near * 1000
        camera.projectionMatrix.makePerspective left, right, top, bottom, near, far

      else
        # We have an orthographic projection.
        near = pixelSize * 10
        far = pixelSize * 10000
        camera.projectionMatrix.makeOrthographic left, right, top, bottom, near, far

      camera.projectionMatrixInverse.getInverse camera.projectionMatrix

      @camera.updated()
