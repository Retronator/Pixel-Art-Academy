AM = Artificial.Mummification
LOI = LandsOfIllusions

_xOffset = 0
_yOffset = 0
_rayOrigin = new THREE.Vector3
_rayDirection = new THREE.Vector3
_ray = new THREE.Ray _rayOrigin, _rayDirection
_worldPoint = new THREE.Vector3

_raycasterPosition = new THREE.Vector3
_raycasterDirection = new THREE.Vector3
_raycasterWorldPoint = new THREE.Vector3

class LOI.Assets.Mesh.CameraAngle
  constructor: (@cameraAngles, @index, data) ->
    @_updatedDependency = new Tracker.Dependency

    # The world matrix transforms from camera (view) space to world space.
    @worldMatrix = new THREE.Matrix4
    
    # The view matrix transforms from world space to view space.
    @viewMatrix = new THREE.Matrix4

    # The custom matrix transforms from view space to custom (distorted) view space.
    @customMatrix4 = new THREE.Matrix4
    @customMatrix4Inverse = new THREE.Matrix4

    @worldToCustomTransform = new THREE.Matrix4
    @customToWorldTransform = new THREE.Matrix4

    @sourceData = {}
    @update data

  toPlainObject: ->
    _.clone @sourceData

  depend: ->
    @_updatedDependency.depend()

  update: (update) ->
    # Update source data and the object itself.
    _.merge @sourceData, update
    _.merge @, update

    worldMatrixChanged = update.position or update.target or update.up
    customMatrixChanged = update.customMatrix

    if worldMatrixChanged
      position = @_createVector @sourceData.position
      target = @_createVector @sourceData.target
      up = @_createVector @sourceData.up

      @worldMatrix.lookAt position, target, up
      @worldMatrix.setPosition position

      @viewMatrix.getInverse @worldMatrix if @worldMatrix.determinant()

    # We need special handling for the custom matrix.
    if customMatrixChanged
      for row in [0..3]
        for column in [0..3]
          # Source index is in row-major order.
          sourceIndex = row * 3 + column

          # Destination index is in column-major order.
          destinationIndex = column * 4 + row

          value = update.customMatrix[sourceIndex]
          @customMatrix4.elements[destinationIndex] = value if value?

      @customMatrix4Inverse.getInverse @customMatrix4 if @customMatrix4.determinant()

    if worldMatrixChanged or customMatrixChanged
      @worldToCustomTransform.copy(@customMatrix4).multiply(@viewMatrix)
      @customToWorldTransform.copy(@worldMatrix).multiply(@customMatrix4Inverse)

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

  _setVector: (vector, vectorData = {}) ->
    vector.set vectorData.x or 0, vectorData.y or 0, vectorData.z or 0
    vector

  getProjectionMatrixForViewport: (viewportBounds, target) ->
    return unless @pixelSize

    # Picture plane offset says where in screen space the origin of the projection (camera position) is.
    offset = @picturePlaneOffset or x: 0, y: 0

    # Note: We offset bounds by half a pixel because we want to look at the center of the pixel.
    left = (viewportBounds.left - 0.5 + offset.x) * @pixelSize
    right = (viewportBounds.right - 0.5 + offset.x) * @pixelSize
    # Note: We want the 3D Y direction to be up, so we need to reverse it (it goes down in screen space).
    top = -(viewportBounds.top - 0.5 + offset.y) * @pixelSize
    bottom = -(viewportBounds.bottom - 0.5 + offset.y) * @pixelSize

    target ?= new THREE.Matrix4

    if @picturePlaneDistance
      # We have a perspective projection.
      near = @picturePlaneDistance
      far = @picturePlaneDistance * 10000
      target.makePerspective left, right, top, bottom, near, far

    else
      # We have an orthographic projection.
      halfSize = 500
      target.makeOrthographic left, right, top, bottom, -halfSize, halfSize

    target.multiply @customMatrix4

  projectPoint: (screenPoint, worldPlane, xOffset = 0, yOffset = 0, projectedWorldPoint) ->
    @_setupProjectionRay xOffset, yOffset

    projectedWorldPoint ?= new THREE.Vector3

    intersection = @_projectPoint screenPoint, worldPlane, projectedWorldPoint
    if intersection then projectedWorldPoint else null

  projectPoints: (screenPoints, worldPlane, xOffset = 0, yOffset = 0) ->
    @_setupProjectionRay xOffset, yOffset
    projectedWorldPoints = []

    for screenPoint in screenPoints
      projectedWorldPoint = new THREE.Vector3
      intersection = @_projectPoint screenPoint, worldPlane, projectedWorldPoint
      projectedWorldPoints.push projectedWorldPoint if intersection

    projectedWorldPoints

  _setupProjectionRay: (xOffset, yOffset) ->
    # The default is a ray from camera position shooting in the -Z direction in custom view space.
    # Note: We need to create vectors from the data which is a plain object.
    _rayOrigin.copy @position
    _rayDirection.set(0, 0, -1).transformDirection @customToWorldTransform

    _xOffset = xOffset
    _yOffset = yOffset

    # Apply picture plane offset.
    if @picturePlaneOffset
      _xOffset += @picturePlaneOffset.x
      _yOffset += @picturePlaneOffset.y

  _projectPoint: (screenPoint, worldPlane, projectedWorldPoint) ->
    # Transform the point from screen space to world, positioned on the picture plane.
    _worldPoint.set screenPoint.x + _xOffset, -(screenPoint.y + _yOffset), -(@picturePlaneDistance or 0)

    # Move from screen space (1 pixel = 1) to custom view space (1 pixel = pixel size).
    _worldPoint.x *= @pixelSize
    _worldPoint.y *= @pixelSize
    
    # Move from custom view space to world space
    _worldPoint.applyMatrix4 @customToWorldTransform

    if @picturePlaneDistance
      # In perspective the ray is shooting through the point in world space.
      _worldPoint.sub(@position).normalize()
      _rayDirection.copy _worldPoint

    else
      # In orthogonal the ray is shooting from the point in world space,
      # but we need to move it backwards behind the world plane.
      _rayOrigin.copy(_rayDirection).multiplyScalar(-500).add _worldPoint

    result = _ray.intersectPlane worldPlane, projectedWorldPoint

    result

  unprojectPoint: (worldPoint) ->
    # Transform to screen space.
    screenPoint = new THREE.Vector3().copy(worldPoint).applyMatrix4 @worldToCustomTransform

    # Scale to screen space.
    screenPoint.x /= @pixelSize
    screenPoint.y /= @pixelSize
    screenPoint.z = 0

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
    cameraPlane = new THREE.Plane(normal.clone()).applyMatrix4 @worldToCustomTransform
    cameraPlane.constant = 0

    horizonDirection = new THREE.Vector3().crossVectors normal, new THREE.Vector3(0, 0, 1)
    horizonDirection = new THREE.Vector2().copy horizonDirection
    horizonDirection.normalize()

    horizonPoint = new THREE.Vector3()
    cameraPlane.projectPoint new THREE.Vector3(0, 0, -1), horizonPoint
    horizonPoint.multiplyScalar 1 / @pixelSize
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

  getRaycaster: (screenPoint, worldMatrix) ->
    raycaster = new THREE.Raycaster
    @updateRaycaster raycaster, screenPoint, worldMatrix
    raycaster

  updateRaycaster: (raycaster, screenPoint, worldMatrix) ->
    # The default is a ray from camera position shooting through the target.
    # Note: We need to create vectors from the data which is a plain object.
    if worldMatrix
      _raycasterPosition.x = worldMatrix.elements[12]
      _raycasterPosition.y = worldMatrix.elements[13]
      _raycasterPosition.z = worldMatrix.elements[14]

      customToWorldTransform = new THREE.Matrix4().copy(worldMatrix).multiply @customMatrix4Inverse

    else
      @_setVector _raycasterPosition, @position

      customToWorldTransform = @customToWorldTransform
      worldMatrix = @worldMatrix

    _raycasterDirection.set(0, 0 , -1).transformDirection customToWorldTransform

    # Apply picture plane offset.
    xOffset = @picturePlaneOffset?.x or 0
    yOffset = @picturePlaneOffset?.y or 0

    # Transform the point from screen space to world, positioned on the picture plane.
    _raycasterWorldPoint.set screenPoint.x + xOffset, -(screenPoint.y + yOffset), -(@picturePlaneDistance or 0)

    # Move from screen space (1 pixel = 1) to custom view space (1 pixel = pixel size).
    _raycasterWorldPoint.x *= @pixelSize
    _raycasterWorldPoint.y *= @pixelSize

    # Move from custom view space to world space
    _raycasterWorldPoint.applyMatrix4 customToWorldTransform

    if @picturePlaneDistance
      # In perspective the ray is shooting through the point in world space.
      _raycasterWorldPoint.sub _raycasterPosition
      _raycasterDirection.copy _raycasterWorldPoint

    else
      # In orthogonal the ray is shooting from the point in world space,
      # but we need to move it backwards behind the near plane.
      _raycasterPosition.copy(_raycasterDirection).multiplyScalar(-500).add _raycasterWorldPoint

    _raycasterDirection.normalize()
    raycaster.set _raycasterPosition, _raycasterDirection
    raycaster
