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

    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')

    # When camera angle changes, match its values via reset.
    @renderer.meshCanvas.autorun (computation) =>
      @reset()

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
    return unless cameraAngle.pixelSize

    cameraAngle.getProjectionMatrixForViewport viewportBounds, _camera.projectionMatrix
    _camera.projectionMatrixInverse.getInverse _camera.projectionMatrix

  _setVector: (vector, vectorData = {}) ->
    vector[field] = vectorData[field] or 0 for field in ['x', 'y', 'z']

  _updateCamera: ->
    @_camera.matrix.lookAt @_position, @_target, @_up
    @_camera.matrix.setPosition @_position
    @_camera.matrix.decompose @_camera.position, @_camera.quaternion, @_camera.scale
    @_updateTargetCamera()

  _updateTargetCamera: ->
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

  transition: (cameraAngle, options) ->
    startPosition = @_camera.position.clone()
    startRotation = @_camera.quaternion.clone()
    startScale = @_camera.scale.clone()

    startProjection = @_camera.projectionMatrix.clone()
    startProjectionRenderTarget = @_renderTargetCamera.projectionMatrix.clone()

    endPosition = new THREE.Vector3
    endRotation = new THREE.Quaternion
    endScale = new THREE.Vector3
    cameraAngle.worldMatrix.decompose endPosition, endRotation, endScale

    viewportBounds = @renderer.meshCanvas.pixelCanvas.camera()?.viewportBounds?.toObject()
    endProjection = cameraAngle.getProjectionMatrixForViewport viewportBounds

    renderTargetViewportBounds =
      left: Math.floor viewportBounds.left
      right: Math.ceil viewportBounds.right
      top: Math.floor viewportBounds.top
      bottom: Math.ceil viewportBounds.bottom

    endProjectionRenderTarget = cameraAngle.getProjectionMatrixForViewport renderTargetViewportBounds

    @$animate.velocity('stop').velocity
      tween: [1, 0]
    ,
      _.extend options,
        progress: (elements, complete, remaining, current, tweenValue) =>
          # Update world matrix parameters.
          @_camera.position.lerpVectors startPosition, endPosition, tweenValue
          THREE.Quaternion.slerp startRotation, endRotation, @_camera.quaternion, tweenValue
          @_camera.scale.lerpVectors startScale, endScale, tweenValue

          # Update projection matrices.
          @_camera.projectionMatrix.lerpMatrices startProjection, endProjection, tweenValue
          @_camera.projectionMatrixInverse.getInverse @_camera.projectionMatrix

          @_renderTargetCamera.projectionMatrix.lerpMatrices startProjectionRenderTarget, endProjectionRenderTarget, tweenValue
          @_renderTargetCamera.projectionMatrixInverse.getInverse @_renderTargetCamera.projectionMatrix

          @_updateTargetCamera()

  reset: ->
    return unless cameraAngle = @renderer.meshCanvas.cameraAngle()

    @_setVector @_position, cameraAngle.position
    @_setVector @_target, cameraAngle.target
    @_setVector @_up, cameraAngle.up

    @_updateCamera()

  getRaycaster: (picturePlanePoint) ->
    return unless cameraAngle = @renderer.meshCanvas.cameraAngle()

    # The default is a ray from camera position shooting through the target.
    # Note: We need to create vectors from the data which is a plain object.
    position = @_position.clone()
    direction = @_target.clone().sub @_position

    # Apply picture plane offset.
    xOffset = cameraAngle.picturePlaneOffset?.x or 0
    yOffset = cameraAngle.picturePlaneOffset?.y or 0

    # Transform the point from screen space to world, positioned on the picture plane.
    worldPoint = new THREE.Vector3 picturePlanePoint.x + xOffset, -(picturePlanePoint.y + yOffset), -(cameraAngle.picturePlaneDistance or 0)
    worldPoint.applyMatrix4 @_camera.matrix

    if cameraAngle.picturePlaneDistance
      # In perspective the ray is shooting through the point in world space.
      direction = worldPoint.sub @_position

    else
      # In orthogonal the ray is shooting from the point in world space.
      position = worldPoint.multiplyScalar cameraAngle.pixelSize

    direction.normalize()

    new THREE.Raycaster position, direction