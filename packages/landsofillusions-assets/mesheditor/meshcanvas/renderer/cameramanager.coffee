AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.CameraManager
  constructor: (@renderer) ->
    # Main camera is used to render the scene in full resolution.
    @_camera = new THREE.Camera

    # Render target camera is the same as main, but slightly bigger viewport rounded to whole pixels.
    @_renderTargetCamera = new THREE.Camera
    @_renderTargetCamera.layers.set 0

    # Pixel render camera is used to render the render target to the screen.
    @_pixelRenderCamera = new THREE.OrthographicCamera

    @camera = new AE.ReactiveWrapper
      main: @_camera
      renderTarget: @_renderTargetCamera
      pixelRender: @_pixelRenderCamera

    @_position = new THREE.Vector3
    @_target = new THREE.Vector3
    @_up = new THREE.Vector3

    # When camera angle changes, match its values.
    @renderer.meshCanvas.autorun (computation) =>
      return unless cameraAngle = @renderer.meshCanvas.cameraAngle()

      @_setVector @_position, cameraAngle.position
      @_setVector @_target, cameraAngle.target
      @_setVector @_up, cameraAngle.up

      @_updateCamera()

    @renderer.meshCanvas.autorun (computation) =>
      return unless viewportBounds = @renderer.meshCanvas.pixelCanvas.camera()?.viewportBounds?.toObject()
      @_updateProjectionMatrix viewportBounds, @_camera

      renderTargetViewportBounds =
        left: Math.floor viewportBounds.left
        right: Math.ceil viewportBounds.right
        top: Math.floor viewportBounds.top
        bottom: Math.ceil viewportBounds.bottom

      @_updateProjectionMatrix renderTargetViewportBounds, @_renderTargetCamera

      @_pixelRenderCamera.left = viewportBounds.left
      @_pixelRenderCamera.right = viewportBounds.right
      @_pixelRenderCamera.top = viewportBounds.top
      @_pixelRenderCamera.bottom = viewportBounds.bottom
      @_pixelRenderCamera.updateProjectionMatrix()

      @camera.updated()

  _updateProjectionMatrix: (viewportBounds, _camera) ->
    return unless cameraAngle = @renderer.meshCanvas.cameraAngle()
    return unless pixelSize = cameraAngle.pixelSize

    # Note: We offset bounds by half a pixel because we want to look at the center of the pixel.
    left = (viewportBounds.left - 0.5) * pixelSize
    right = (viewportBounds.right - 0.5) * pixelSize
    # Note: We want the 3D Y direction to be up, so we need to reverse it (it goes down in screen space).
    top = -(viewportBounds.top - 0.5) * pixelSize
    bottom = -(viewportBounds.bottom - 0.5) * pixelSize
    near = pixelSize
    far = 1000

    if picturePlaneDistance = cameraAngle.picturePlaneDistance
      # We have a perspective projection.
      near *= picturePlaneDistance
      _camera.projectionMatrix.makePerspective left, right, top, bottom, near, far

    else
      # We have an orthographic projection.
      _camera.projectionMatrix.makeOrthographic left, right, top, bottom, near, far

    _camera.projectionMatrixInverse.getInverse _camera.projectionMatrix

  _setVector: (vector, vectorData = {}) ->
    vector[field] = vectorData[field] or 0 for field in ['x', 'y', 'z']

  _updateCamera: ->
    @_camera.matrix.lookAt @_position, @_target, @_up
    @_camera.matrix.setPosition @_position
    @_camera.matrix.decompose @_camera.position, @_camera.quaternion, @_camera.scale

    @_renderTargetCamera.matrix.copy @_camera.matrix
    @_renderTargetCamera.matrix.decompose @_renderTargetCamera.position, @_renderTargetCamera.quaternion, @_renderTargetCamera.scale

    @camera.updated()

  move: (deltaX, deltaY) ->
    delta = @_createDelta deltaX, deltaY

    @_position.add delta
    @_target.add delta

    @_updateCamera()

  _createDelta: (deltaX, deltaY) ->
    scale = @renderer.meshCanvas.cameraAngle().pixelSize

    delta = new THREE.Vector3 deltaX * scale, deltaY * scale
    delta.applyQuaternion @_camera.quaternion

  moveAroundTarget: (deltaX, deltaY) ->
    delta = @_createDelta deltaX, deltaY

    distanceToTarget = @_position.distanceTo @_target

    @_position.add delta

    # Preserve distance to target.
    @_position.subVectors(@_position, @_target).normalize().multiplyScalar(distanceToTarget).add @_target

    @_updateCamera()
