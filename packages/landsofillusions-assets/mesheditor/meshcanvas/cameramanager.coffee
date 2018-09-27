AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.CameraManager
  constructor: (@meshCanvas, @options = {}) ->
    camera = new THREE.Camera
    @camera = new AE.ReactiveWrapper camera

    @meshCanvas.autorun (computation) =>
      return unless cameraAngle = @meshCanvas.options.cameraAngle()

      camera.matrix.copy cameraAngle.worldMatrix
      camera.matrix.decompose camera.position, camera.quaternion, camera.scale

      @camera.updated()

    @meshCanvas.autorun (computation) =>
      return unless viewportBounds = @meshCanvas.options.pixelCanvas()?.camera()?.viewportBounds
      return unless cameraAngle = @meshCanvas.options.cameraAngle()
      return unless pixelSize = cameraAngle.pixelSize

      # Note: We offset bounds by half a pixel because we want to look at the center of the pixel.
      left = (viewportBounds.left() - 0.5) * pixelSize
      right = (viewportBounds.right() - 0.5) * pixelSize
      # Note: We want the 3D Y direction to be up, so we need to reverse it (it goes down in screen space).
      top = -(viewportBounds.top() - 0.5) * pixelSize
      bottom = -(viewportBounds.bottom() - 0.5) * pixelSize
      near = pixelSize
      far = 1000

      if picturePlaneDistance = cameraAngle.picturePlaneDistance
        # We have a perspective projection.
        near *= picturePlaneDistance
        camera.projectionMatrix.makePerspective left, right, top, bottom, near, far

      else
        # We have an orthographic projection.
        camera.projectionMatrix.makeOrthographic left, right, top, bottom, near, far

      camera.projectionMatrixInverse.getInverse camera.projectionMatrix

      @camera.updated()
