AS = Artificial.Spectrum
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.Navigator
  constructor: (@world) ->
    @_movements = []

    @_direction = new THREE.Vector3

  moveAvatar: (options) ->
    # Remove any existing movements for this avatar.
    _.remove @_movements, (movement) => movement.options.avatar is options.avatar
      
    target = LOI.adventure.world.getPositionVector options.target
    path = [THREE.Vector3.fromObject target]

    movement = {options, path}
    @_movements.push movement

  update: (appTime) ->
    for movement in @_movements
      physicsObject = movement.options.avatar.getPhysicsObject()
      position = physicsObject.getPosition()

      unless movement.pathSegment
        # Set the next path segment.
        end = movement.path[0]
        movement.pathSegment = new THREE.Line3 position, end

      # Update path segment start each frame to avatar's actual position.
      movement.pathSegment.start = position

      # Direct the avatar towards the segment end.
      @_direction.copy(movement.pathSegment.end).sub position
      @_direction.normalize()

      renderObject = movement.options.avatar.getRenderObject()
      renderObject.faceDirection? @_direction

      # Move the avatar in the desired direction.
      distance = appTime.elapsedAppTime * movement.options.speed
      newPosition = @_direction.multiplyScalar(distance).add position
      physicsObject.setPosition newPosition

      # See if we've reached the end of the path segment.
      unless distance and movement.pathSegment.closestPointToPointParameter(newPosition) < 1
        # See if this is the end of the path.
        if movement.path.length is 1
          # Position the avatar directly to the end point.
          physicsObject.setPosition movement.path[0]

          # Notify that the movement has completed.
          movement.options.onCompleted?()

        # Remove this path segment.
        movement.pathSegment = null
        movement.path.shift()

    # Remove all movements that have completed.
    _.remove @_movements, (movement) => movement.path.length is 0
