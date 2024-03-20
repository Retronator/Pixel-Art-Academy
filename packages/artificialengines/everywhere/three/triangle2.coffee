_v0 = new THREE.Vector2
_v1 = new THREE.Vector2
_v2 = new THREE.Vector2
_v3 = new THREE.Vector2

class THREE.Triangle2
  @getBarycoord: (point, a, b, c, target) ->
    _v0.subVectors c, a
    _v1.subVectors b, a
    _v2.subVectors point, a
    
    dot00 = _v0.dot _v0
    dot01 = _v0.dot _v1
    dot02 = _v0.dot _v2
    dot11 = _v1.dot _v1
    dot12 = _v1.dot _v2
    
    denom = dot00 * dot11 - (dot01 * dot01)
    
    # Check if this is a collinear or singular triangle.
    unless denom
      target.set 0, 0, 0
      return null
      
    invDenom = 1 / denom
    u = (dot11 * dot02 - (dot01 * dot12)) * invDenom
    v = (dot00 * dot12 - (dot01 * dot02)) * invDenom
    
    # Barycentric coordinates must always sum to 1.
    target.set 1 - u - v, v, u
    
  @containsPoint: (point, a, b, c) ->
    # If the triangle is degenerate, we can't contain a point.
    return false unless @getBarycoord point, a, b, c, _v3
    
    _v3.x >= 0 and _v3.y >= 0 and _v3.x + _v3.y <= 1
  
  constructor: (@a, @b, @c) ->
    @a ?= new THREE.Vector2
    @b ?= new THREE.Vector2
    @c ?= new THREE.Vector2
    
  set: (a, b, c) ->
    @a.copy a
    @b.copy b
    @c.copy c
    @
    
  clone: ->
    new @constructor().copy @
  
  copy: (triangle) ->
    @a.copy triangle.a
    @b.copy triangle.b
    @c.copy triangle.c
    @
    
