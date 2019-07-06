AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.CameraAngle
  constructor: (@cameraAngles, @index, data) ->
    @_updatedDependency = new Tracker.Dependency

    @worldMatrix = new THREE.Matrix4
    @worldMatrixInverse = new THREE.Matrix4

    @sourceData = {}
    @update data

  toPlainObject: ->
    @sourceData

  depend: ->
    @_updatedDependency.depend()

  update: (update) ->
    # Update source data and the object itself.
    _.merge @sourceData, update
    _.merge @, update

    position = @_createVector @sourceData.position
    target = @_createVector @sourceData.target
    up = @_createVector @sourceData.up

    @worldMatrix.lookAt position, target, up
    @worldMatrix.setPosition position

    @worldMatrixInverse.getInverse @worldMatrix if @worldMatrix.determinant()

    # Signal change of the camera angle.
    @_updatedDependency.changed()
    @cameraAngles.contentUpdated()

    mesh = @cameraAngles.parent

    # Update solvers after the objects have been initialized as an array field.
    if mesh.objects instanceof LOI.Assets.Mesh.ArrayField
      for object in mesh.objects.getAllWithoutUpdates() when object
        object.solver.recompute()

  _createVector: (vectorData = {}) ->
    new THREE.Vector3 vectorData.x or 0, vectorData.y or 0, vectorData.z or 0

  getProjectionMatrixForViewport: (viewportBounds, target) ->
    return unless @pixelSize
    
    offset = @picturePlaneOffset or x: 0, y: 0

    # Note: We offset bounds by half a pixel because we want to look at the center of the pixel.
    left = (viewportBounds.left - 0.5 + offset.x) * @pixelSize
    right = (viewportBounds.right - 0.5 + offset.x) * @pixelSize
    # Note: We want the 3D Y direction to be up, so we need to reverse it (it goes down in screen space).
    top = -(viewportBounds.top - 0.5 + offset.y) * @pixelSize
    bottom = -(viewportBounds.bottom - 0.5 + offset.y) * @pixelSize
    near = @pixelSize
    far = 1000

    target ?= new THREE.Matrix4

    if @picturePlaneDistance
      # We have a perspective projection.
      near *= @picturePlaneDistance
      target.makePerspective left, right, top, bottom, near, far

    else
      # We have an orthographic projection.
      target.makeOrthographic left, right, top, bottom, near, far

    target

  projectPoints: (screenPoints, worldPlane, xOffset = 0, yOffset = 0) ->
    projectedWorldPoints = []

    # The default is a ray from camera position shooting through the target.
    # Note: We need to create vectors from the data which is a plain object.
    position = new THREE.Vector3().copy @position
    direction = new THREE.Vector3().copy(@target).sub position

    # Apply picture plane offset.
    if @picturePlaneOffset
      xOffset += @picturePlaneOffset.x
      yOffset += @picturePlaneOffset.y

    for screenPoint in screenPoints
      # Transform the point from screen space to world, positioned on the picture plane.
      worldPoint = new THREE.Vector3 screenPoint.x + xOffset, -(screenPoint.y + yOffset), -(@picturePlaneDistance or 0)
      worldPoint.applyMatrix4 @worldMatrix

      if @picturePlaneDistance
        # In perspective the ray is shooting through the point in world space.
        direction = worldPoint.clone().sub(@position).normalize()

      else
        # In orthogonal the ray is shooting from the point in world space.
        position = worldPoint.multiplyScalar @pixelSize

      ray = new THREE.Ray position, direction

      projectedWorldPoint = new THREE.Vector3
      intersection = ray.intersectPlane worldPlane, projectedWorldPoint

      projectedWorldPoints.push projectedWorldPoint if intersection

    projectedWorldPoints

  unprojectPoint: (worldPoint) ->
    # Transform to screen space.
    screenPoint = new THREE.Vector3().copy(worldPoint).applyMatrix4 @worldMatrixInverse

    # Scale to picture plane.
    screenPoint.multiplyScalar -@picturePlaneDistance / screenPoint.z

    # Screen space has positive Y going down.
    screenPoint.y *= -1

    # Apply picture plane offset.
    if @picturePlaneOffset
      screenPoint.x -= @picturePlaneOffset.x
      screenPoint.y -= @picturePlaneOffset.y

    screenPoint

  getHorizon: (normal) ->
    # We transform the plane into camera space and put it to zero since all parallel planes will intersect in same spot.
    # Note: We need to clone the normal since the plane will directly use the given vector.
    cameraPlane = new THREE.Plane(normal.clone()).applyMatrix4 @worldMatrixInverse
    cameraPlane.constant = 0

    horizonDirection = new THREE.Vector3().crossVectors normal, new THREE.Vector3(0, 0, 1)
    horizonDirection = new THREE.Vector2().copy horizonDirection
    horizonDirection.normalize()

    horizonPoint = new THREE.Vector3()
    cameraPlane.projectPoint new THREE.Vector3(0, 0, -1), horizonPoint
    horizonPoint.multiplyScalar -@picturePlaneDistance / horizonPoint.z
    horizonPoint = new THREE.Vector2().copy horizonPoint

    # Apply plane picture offset.
    if @picturePlaneOffset
      horizonPoint.x += @picturePlaneOffset.x
      horizonPoint.y += @picturePlaneOffset.y

    # To go to screen space, Y needs to be negated.
    horizonDirection.y *= -1
    horizonPoint.y *= -1

    origin: horizonPoint
    direction: horizonDirection

  distanceInDirectionToHorizon: (screenPoint, direction, horizon) ->
    denominator = direction.cross horizon.direction
    return Number.POSITIVE_INFINITY unless denominator

    new THREE.Vector2().subVectors(horizon.origin, screenPoint).cross(horizon.direction) / denominator

  distanceToHorizon: (screenPoint, horizon) ->
    pointToHorizonOrigin = new THREE.Vector2().subVectors horizon.origin, screenPoint
    projectionLength = pointToHorizonOrigin.dot horizon.direction
    direction = pointToHorizonOrigin.clone().sub horizon.direction.clone().multiplyScalar projectionLength

    denominator = direction.cross horizon.direction
    return Number.POSITIVE_INFINITY unless denominator

    pointToHorizonOrigin.cross(horizon.direction) / Math.abs denominator

  getRaycaster: (screenPoint) ->
    # The default is a ray from camera position shooting through the target.
    # Note: We need to create vectors from the data which is a plain object.
    position = @_createVector @position
    direction = @_createVector(@target).sub position

    # Apply picture plane offset.
    xOffset = @picturePlaneOffset?.x or 0
    yOffset = @picturePlaneOffset?.y or 0

    # Transform the point from screen space to world, positioned on the picture plane.
    worldPoint = new THREE.Vector3 screenPoint.x + xOffset, -(screenPoint.y + yOffset), -(@picturePlaneDistance or 0)
    worldPoint.applyMatrix4 @worldMatrix

    if @picturePlaneDistance
      # In perspective the ray is shooting through the point in world space.
      direction = worldPoint.sub @position

    else
      # In orthogonal the ray is shooting from the point in world space.
      position = worldPoint.multiplyScalar @pixelSize

    direction.normalize()

    new THREE.Raycaster position, direction
