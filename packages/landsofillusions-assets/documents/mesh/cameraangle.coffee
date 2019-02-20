AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.CameraAngle
  constructor: (data) ->
    _.extend @, data

    position = @_createVector @position
    target = @_createVector @target
    up = @_createVector @up

    @worldMatrix = new THREE.Matrix4().lookAt position, target, up
    @worldMatrix.setPosition position

    return unless @worldMatrix.determinant()

    @worldMatrixInverse = new THREE.Matrix4().getInverse @worldMatrix

  _createVector: (vectorData = {}) ->
    new THREE.Vector3 vectorData.x or 0, vectorData.y or 0, vectorData.z or 0

  projectPoints: (screenPoints, worldPlane, xOffset = 0, yOffset = 0) ->
    projectedWorldPoints = []

    # The default is a ray from camera position shooting through the target.
    # Note: We need to create vectors from the data which is a plain object.
    position = new THREE.Vector3().copy @position
    direction = new THREE.Vector3().copy(@target).sub position

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

    # Screen scape has positive Y going down.
    screenPoint.y *= -1

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

    # To go to screen space, Y needs to be negated.
    horizonDirection.y *= -1
    horizonPoint.y *= -1

    origin: horizonPoint
    direction: horizonDirection

  distanceInDirectionToHorizon: (screenPoint, direction, horizon) ->
    denominator = direction.cross horizon.direction
    return Number.POSITIVE_INFINITY unless denominator

    new THREE.Vector2().subVectors(horizon.origin, screenPoint).cross(horizon.direction) / denominator