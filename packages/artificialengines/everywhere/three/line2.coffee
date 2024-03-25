_startP = new THREE.Vector2
_startEnd = new THREE.Vector2

_line1Position = new THREE.Vector2
_line1Direction = new THREE.Vector2
_line2Position = new THREE.Vector2
_line2Direction = new THREE.Vector2
_positionDifference = new THREE.Vector2

_delta = new THREE.Vector2
_normal = new THREE.Vector2

class THREE.Line2
  constructor: (@start, @end) ->
    @start ?= new THREE.Vector2
    @end ?= new THREE.Vector2
    
  set: (start, end) ->
    @start.copy start
    @end.copy end
    @
    
  copy: (line) ->
    @start.copy line.start
    @end.copy line.end
    @

  getCenter: (target) ->
    target.addVectors(@start, @end).multiplyScalar 0.5

  delta: (target)  ->
    target.subVectors @end, @start

  distanceSq: ->
    @start.distanceToSquared @end

  distance: ->
    @start.distanceTo @end
  
  at: (t, target) ->
    @delta(target).multiplyScalar(t).add @start

  closestPointToPointParameter: (point, clampToLine) ->
    _startP.subVectors point, @start
    _startEnd.subVectors @end, @start

    startEnd2 = _startEnd.dot _startEnd
    startEnd_startP = _startEnd.dot _startP

    t = startEnd_startP / startEnd2

    if clampToLine
      t = THREE.MathUtils.clamp t, 0, 1

    t

  closestPointToPoint: (point, clampToLine, target) ->
    t = @closestPointToPointParameter point, clampToLine

    @delta(target).multiplyScalar(t).add @start

  applyMatrix4: (matrix) ->
    @start.applyMatrix4 matrix
    @end.applyMatrix4 matrix
    @

  equals: (line) ->
    line.start.equals(@start) and line.end.equals(@end)

  clone: ->
    new @constructor().copy @
    
  intersect: (extendedLine, target) ->
    # Note: We treat both lines as extended lines (going into infinity).
    distanceFromStart = @intersectionDistanceFromStart extendedLine
    return false if distanceFromStart is false
    
    _line1Position.copy @start
    @delta(_line1Direction)
    _line1Direction.normalize()
    target.copy(_line1Direction).multiplyScalar(distanceFromStart).add _line1Position
    
    true
  
  intersects: (line) ->
    @intersectsExtendedLine(line) and line.intersectsExtendedLine(@)
    
  intersectsExtendedLine: (extendedLine) ->
    distanceFromStart = @intersectionDistanceFromStart extendedLine
    return false if distanceFromStart is false
    
    Number.EPSILON < distanceFromStart < @distance() - Number.EPSILON
  
  intersectionDistanceFromStart: (extendedLine) ->
    _line1Position.copy @start
    @delta(_line1Direction)
    _line1Direction.normalize()
    
    _line2Position.copy extendedLine.start
    extendedLine.delta(_line2Direction)
    _line2Direction.normalize()
    
    # There is no intersection if lines are parallel (cross product of direction vectors is zero).
    directionCross = _line1Direction.cross _line2Direction
    return false if Math.abs(directionCross) < Number.EPSILON
    
    _positionDifference.subVectors _line2Position, _line1Position
    _positionDifference.cross(_line2Direction) / directionCross
    
  getNormal: (right, result) ->
    result ?= new THREE.Vector2
    @delta _delta
    
    if right
      result.x = _delta.y
      result.y = -_delta.x
    else
      result.x = -_delta.y
      result.y = _delta.x
    
    result.normalize()
    result
    
  getSignedDistanceFromLine: (point) ->
    # Positive distance is to the right of the line.
    @getNormal true, _normal
    distanceToLine = _normal.dot @start
    distanceToPoint = _normal.dot point
    
    distanceToPoint - distanceToLine
    
  getDistanceFromLine: (point) ->
    Math.abs @getSignedDistanceFromLine()
    
  isPointInRightHalfPlane: (point) ->
    @getSignedDistanceFromLine(point) > 0

  isPointInLeftHalfPlane: (point) ->
    @getSignedDistanceFromLine(point) < 0
