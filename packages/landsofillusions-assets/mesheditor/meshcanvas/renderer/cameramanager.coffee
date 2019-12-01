AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions

viewportBounds = left: 0, right: 0, top: 0, bottom: 0
renderTargetViewportBounds = left: 0, right: 0, top: 0, bottom: 0

class LOI.Assets.MeshEditor.MeshCanvas.Renderer.CameraManager
  constructor: (@renderer) ->
    # Main camera is used to render the scene in full resolution.
    @_camera = new THREE.Camera
    @_camera.matrixAutoUpdate = false

    # Render target camera is the same as main, but slightly bigger viewport rounded to whole pixels.
    @_renderTargetCamera = new THREE.Camera
    @_renderTargetCamera.layers.set 0
    @_renderTargetCamera.matrixAutoUpdate = false

    # Pixel render camera is used to render the render target to the screen.
    @_pixelRenderCamera = new THREE.OrthographicCamera

    @camera = new AE.ReactiveWrapper
      main: @_camera
      renderTarget: @_renderTargetCamera
      pixelRender: @_pixelRenderCamera

    @_position = new THREE.Vector3
    @_target = new THREE.Vector3
    @_up = new THREE.Vector3

    @_customMatrix = new THREE.Matrix4
    @_identityMatrix = new THREE.Matrix4

    # Dummy DOM element to run velocity on.
    @$animate = $('<div>')

    # Minimize reactivity of camera angle updates.
    @currentCameraAngle = new ComputedField =>
      @renderer.meshCanvas.cameraAngle()
    ,
      (a, b) => a is b
    ,
      true

    # Continuously update camera when camera angle changes.
    @renderer.meshCanvas.autorun (computation) =>
      @reset()

    @renderer.meshCanvas.autorun (computation) =>
      return unless viewportBoundsRectangle = @renderer.meshCanvas.pixelCanvas.camera()?.viewportBounds

      viewportBounds.left = viewportBoundsRectangle.left()
      viewportBounds.right = viewportBoundsRectangle.right()
      viewportBounds.top = viewportBoundsRectangle.top()
      viewportBounds.bottom = viewportBoundsRectangle.bottom()
      @_updateProjectionMatrix viewportBounds, @_camera

      renderTargetViewportBounds.left = Math.floor viewportBounds.left
      renderTargetViewportBounds.right = Math.ceil viewportBounds.right
      renderTargetViewportBounds.top = Math.floor viewportBounds.top
      renderTargetViewportBounds.bottom = Math.ceil viewportBounds.bottom
      @_updateProjectionMatrix renderTargetViewportBounds, @_renderTargetCamera

      @_pixelRenderCamera.left = viewportBounds.left
      @_pixelRenderCamera.right = viewportBounds.right
      @_pixelRenderCamera.top = viewportBounds.top
      @_pixelRenderCamera.bottom = viewportBounds.bottom
      @_pixelRenderCamera.updateProjectionMatrix()

      console.log "Viewport bounds changed", viewportBounds, renderTargetViewportBounds, @_pixelRenderCamera if LOI.Assets.debug

      @camera.updated()

  _updateProjectionMatrix: (viewportBounds, _camera) ->
    return unless cameraAngle = @renderer.meshCanvas.cameraAngle()
    return unless cameraAngle.pixelSize

    @_setMatrix @_customMatrix, cameraAngle.customMatrix

    cameraAngle.getProjectionMatrixForViewport viewportBounds, _camera.projectionMatrix
    #_camera.projectionMatrix.premultiply @_customMatrix
    _camera.projectionMatrixInverse.getInverse _camera.projectionMatrix

  _setVector: (vector, vectorData = {}) ->
    vector[field] = vectorData[field] or 0 for field in ['x', 'y', 'z']

  _setMatrix: (matrix, matrixData = []) ->
    for element, index in @_identityMatrix.elements
      matrix.elements[index] = matrixData[index] ? element

  _updateCamera: ->
    @_camera.matrix.copy @_identityMatrix
    @_camera.matrix.lookAt @_position, @_target, @_up
    @_camera.matrix.setPosition @_position
    @_camera.matrix.decompose @_camera.position, @_camera.quaternion, @_camera.scale

    @_updateTargetCamera()

    @_camera.matrix.multiply @_customMatrix
    @_camera.matrixWorldNeedsUpdate = true

    @camera.updated()

  _updateTargetCamera: ->
    @_renderTargetCamera.matrix.copy @_camera.matrix
    @_renderTargetCamera.matrix.decompose @_renderTargetCamera.position, @_renderTargetCamera.quaternion, @_renderTargetCamera.scale

    @_renderTargetCamera.matrix.multiply @_customMatrix
    @_renderTargetCamera.matrixWorldNeedsUpdate = true

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
          @_camera.updateMatrix()

          # Update projection matrices.
          @_camera.projectionMatrix.lerpMatrices startProjection, endProjection, tweenValue
          @_camera.projectionMatrixInverse.getInverse @_camera.projectionMatrix

          @_renderTargetCamera.projectionMatrix.lerpMatrices startProjectionRenderTarget, endProjectionRenderTarget, tweenValue
          @_renderTargetCamera.projectionMatrixInverse.getInverse @_renderTargetCamera.projectionMatrix

          @_updateTargetCamera()

          #@_camera.matrix.multiply @_customMatrix

  reset: ->
    return unless cameraAngle = @currentCameraAngle()
    cameraAngle.depend()

    @_setVector @_position, cameraAngle.position
    @_setVector @_target, cameraAngle.target
    @_setVector @_up, cameraAngle.up

    @_setMatrix @_customMatrix, cameraAngle.customMatrix

    @_updateCamera()

  getRaycaster: (picturePlanePoint) ->
    @renderer.meshCanvas.cameraAngle()?.getRaycaster picturePlanePoint
