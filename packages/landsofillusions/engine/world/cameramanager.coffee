AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Engine.World.CameraManager
  constructor: (@world) ->
    @_camera = new THREE.Camera
    @camera = new AE.ReactiveWrapper @_camera

    @_position = new THREE.Vector3
    @_target = new THREE.Vector3
    @_up = new THREE.Vector3

    @cameraAngle = new ReactiveField null

    # Update projection matrix when viewport changes.
    @world.autorun (computation) =>
      return unless @cameraAngle()?.pixelSize
      @_updateProjectionMatrix()
      @camera.updated()

    # Dummy DOM element to run velocity on.
    @_$animate = $('<div>')

  _updateWorldMatrix: ->
    @_camera.matrix.lookAt @_position, @_target, @_up
    @_camera.matrix.setPosition @_position
    @_camera.matrix.decompose @_camera.position, @_camera.quaternion, @_camera.scale

  _updateProjectionMatrix: ->
    viewportBounds = @_getViewportBounds()
    @cameraAngle().getProjectionMatrixForViewport viewportBounds, @_camera.projectionMatrix
    @_camera.projectionMatrixInverse.getInverse @_camera.projectionMatrix

  _getViewportBounds: ->
    # Depend on illustration size changes.
    illustrationSize = @world.options.adventure.interface.illustrationSize
    halfWidth = illustrationSize.width() / 2
    halfHeight = illustrationSize.height() / 2

    left: -halfWidth
    right: halfWidth
    top: -halfHeight
    bottom: halfHeight

  setFromCameraAngle: (cameraAngle) ->
    @_setVector @_position, cameraAngle.position
    @_setVector @_target, cameraAngle.target
    @_setVector @_up, cameraAngle.up

    @_updateWorldMatrix()

    # Setting the new camera angle will trigger projection matrix update and reactive changes.
    @cameraAngle cameraAngle

  _setVector: (vector, vectorData = {}) ->
    vector[field] = vectorData[field] or 0 for field in ['x', 'y', 'z']

  transitionToCameraAngle: (cameraAngle, options) ->
    startPosition = @_camera.position.clone()
    startRotation = @_camera.quaternion.clone()
    startScale = @_camera.scale.clone()

    startProjection = @_camera.projectionMatrix.clone()

    endPosition = new THREE.Vector3
    endRotation = new THREE.Quaternion
    endScale = new THREE.Vector3
    cameraAngle.worldMatrix.decompose endPosition, endRotation, endScale

    viewportBounds = @_getViewportBounds()
    endProjection = cameraAngle.getProjectionMatrixForViewport viewportBounds

    @_$animate.velocity('stop').velocity
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

          @camera.updated()

        complete: =>
          @cameraAngle cameraAngle

  getRaycaster: (screenPoint) ->
    @cameraAngle()?.getRaycaster screenPoint

  updateRaycaster: (raycaster, screenPoint) ->
    @cameraAngle()?.updateRaycaster raycaster, screenPoint
