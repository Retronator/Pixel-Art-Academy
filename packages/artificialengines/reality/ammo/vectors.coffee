# Extra functionality for the vector classes.

# Convert the vector to a plain object.
Ammo.btVector3::toObject = ->
  x: @x()
  y: @y()
  z: @z()

Ammo.btVector3::toThreeVector3 = ->
  new THREE.Vector3 @x(), @y(), @z()

Ammo.btVector3::setFromThreeVector3 = (threeVector3) ->
  @setX threeVector3.x
  @setY threeVector3.y
  @setZ threeVector3.z

# Create a new vector from a plain object.
Ammo.btVector3.fromObject = (object) ->
  return new Ammo.btVector3 object.x, object.y, object.z
