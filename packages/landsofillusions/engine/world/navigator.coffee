AS = Artificial.Spectrum
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.Navigator
  constructor: (@world) ->
    @_movements = []

  movePhysicsObject: (options) ->
    # Remove any existing movements for this physics object.
    _.remove @_movements, (movement) => movement.options.physicsObject is options.physicsObject
      
    target = LOI.adventure.world.getPositionVector options.target
    path = [THREE.Vector3.fromObject target]

    movement = {options, path}
    @_movements.push movement

  update: (appTime) ->
    for movement in @_movements
      unless movement.pathSegment
        # Set the next path segment.
        start = movement.options.physicsObject.getPosition()
        end = movement.path[0]
        movement.pathSegment = new THREE.Line3 start, end

        # Direct the object towards the segment end.
        movement.direction = new THREE.Vector3().subVectors end, start
        movement.direction.normalize()
        movement.options.physicsObject.faceDirection? movement.direction

      # Move the object in the desired direction.
      distance = appTime.elapsedAppTime * movement.options.speed
      newPosition = movement.direction.clone().multiplyScalar(distance).add movement.options.physicsObject.getPosition()
      movement.options.physicsObject.setPosition newPosition

      # See if we've reached the end of the path segment.
      unless distance and movement.pathSegment.closestPointToPointParameter(newPosition) < 1
        # See if this is the end of the path.
        if movement.path.length is 1
          # Position the object directly to the end point.
          movement.options.physicsObject.setPosition movement.path[0]

          # Notify that the movement has completed.
          movement.options.onCompleted?()

        # Remove this path segment.
        movement.pathSegment = null
        movement.path.shift()

    # Remove all movements that have completed.
    _.remove @_movements, (movement) => movement.path.length is 0
