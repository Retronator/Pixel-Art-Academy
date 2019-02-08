AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Engine.World.CameraManager
  constructor: (@world) ->
    @_camera = new THREE.Camera
    @camera = new AE.ReactiveWrapper @_camera

    @_position = new THREE.Vector3
    @_target = new THREE.Vector3
    @_up = new THREE.Vector3

    @_cameraAngle = null

    # Update projection matrix when viewport changes.
    @world.autorun (computation) =>
      return unless @_cameraAngle?.pixelSize
      @_updateProjectionMatrix()
      @camera.updated()

  _updateWorldMatrix: ->
    @_camera.matrix.lookAt @_position, @_target, @_up
    @_camera.matrix.setPosition @_position
    @_camera.matrix.decompose @_camera.position, @_camera.quaternion, @_camera.scale

  _updateProjectionMatrix: ->
    # Depend on illustration size changes.
    illustrationSize = @world.options.adventure.interface.illustrationSize
    halfWidth = illustrationSize.width() / 2
    halfHeight = illustrationSize.height() / 2

    viewportBounds =
      left: -halfWidth
      right: halfWidth
      top: -halfHeight
      bottom: halfHeight

    @_cameraAngle.getProjectionMatrixForViewport viewportBounds, @_camera.projectionMatrix
    @_camera.projectionMatrixInverse.getInverse @_camera.projectionMatrix

  setFromCameraAngle: (cameraAngle) ->
    @_cameraAngle = cameraAngle

    @_setVector @_position, cameraAngle.position
    @_setVector @_target, cameraAngle.target
    @_setVector @_up, cameraAngle.up

    @_updateWorldMatrix()
    @_updateProjectionMatrix()
    @camera.updated()

  _setVector: (vector, vectorData = {}) ->
    vector[field] = vectorData[field] or 0 for field in ['x', 'y', 'z']

