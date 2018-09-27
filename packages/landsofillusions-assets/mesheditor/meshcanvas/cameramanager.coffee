AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.CameraManager
  constructor: (@meshCanvas, @options = {}) ->
    @_camera = new THREE.Camera
    @camera = new AE.ReactiveWrapper @_camera

    @_position = new THREE.Vector3
    @_target = new THREE.Vector3
    @_up = new THREE.Vector3

    # When camera angle changes, match its values.
    @meshCanvas.autorun (computation) =>
      return unless cameraAngle = @meshCanvas.options.cameraAngle()

      @_setVector @_position, cameraAngle.position
      @_setVector @_target, cameraAngle.target
      @_setVector @_up, cameraAngle.up

      @_updateCamera()

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
        @_camera.projectionMatrix.makePerspective left, right, top, bottom, near, far

      else
        # We have an orthographic projection.
        @_camera.projectionMatrix.makeOrthographic left, right, top, bottom, near, far

      @_camera.projectionMatrixInverse.getInverse @_camera.projectionMatrix

      @camera.updated()

  _setVector: (vector, vectorData = {}) ->
    vector[field] = vectorData[field] or 0 for field in ['x', 'y', 'z']

  _updateCamera: ->
    @_camera.matrix.lookAt @_position, @_target, @_up
    @_camera.matrix.setPosition @_position
    @_camera.matrix.decompose @_camera.position, @_camera.quaternion, @_camera.scale

    @camera.updated()

  move: (deltaX, deltaY) ->
    delta = @_createDelta deltaX, deltaY

    @_position.add delta
    @_target.add delta

    @_updateCamera()

  _createDelta: (deltaX, deltaY) ->
    scale = @meshCanvas.options.cameraAngle().pixelSize

    delta = new THREE.Vector3 deltaX * scale, deltaY * scale
    delta.applyQuaternion @_camera.quaternion

  moveAroundTarget: (deltaX, deltaY) ->
    delta = @_createDelta deltaX, deltaY

    distanceToTarget = @_position.distanceTo @_target

    @_position.add delta

    # Preserve distance to target.
    @_position.subVectors(@_position, @_target).normalize().multiplyScalar(distanceToTarget).add @_target

    @_updateCamera()
