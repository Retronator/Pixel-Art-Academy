# Extra functionality for the vector classes.

# Convert the vector to a plain object.
THREE.Vector3::toObject = ->
  x: @x
  y: @y
  z: @z

THREE.Vector3::toBulletVector3 = ->
  new Ammo.btVector3 @x, @y, @z

THREE.Vector3::setFromBulletVector3 = (bulletVector3) ->
  @x = bulletVector3.x()
  @y = bulletVector3.y()
  @z = bulletVector3.z()

THREE.Vector3::exp = ->
  @x = Math.exp @x
  @y = Math.exp @y
  @z = Math.exp @z

# Create a new vector from a plain object.
THREE.Vector3.fromObject = (object) ->
  return new THREE.Vector3().copy object
