AS = Artificial.Spectrum
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.Navigator
  constructor: (@world) ->
    @_movements = []

    @_position = new THREE.Vector3
    @_direction = new THREE.Vector3
    
    @spaceOccupation = new @constructor.SpaceOccupation @

  moveAvatar: (options) ->
    # Remove any existing movements for this avatar.
    _.remove @_movements, (movement) =>
      return unless movement.options.avatar is options.avatar

      # Cancel the movement as well.
      movement.options.onCanceled?()
      true
      
    target = LOI.adventure.world.getPositionVector options.target
    path = [THREE.Vector3.fromObject target]

    movement = {options, path}
    @_movements.push movement

  update: (appTime) ->
    for movement in @_movements
      physicsObject = movement.options.avatar.getPhysicsObject()
      physicsObject.getPosition @_position

      unless movement.pathSegment
        # Set the next path segment.
        end = @spaceOccupation.findEmptySpace movement.options.avatar, movement.path[0]
        movement.pathSegment = new THREE.Line3 @_position, end
        physicsObject.targetPosition = end

      # Update path segment start each frame to avatar's actual position.
      movement.pathSegment.start = @_position

      # Direct the avatar towards the segment end.
      @_direction.copy(movement.pathSegment.end).sub @_position
      @_direction.normalize()

      renderObject = movement.options.avatar.getRenderObject()
      renderObject.faceDirection? @_direction

      # Move the avatar in the desired direction.
      distance = appTime.elapsedAppTime * movement.options.speed
      newPosition = @_direction.multiplyScalar(distance).add @_position
      physicsObject.setPosition newPosition

      # See if we've reached the end of the path segment.
      unless distance and movement.pathSegment.closestPointToPointParameter(newPosition) < 1
        # See if this is the end of the path.
        if movement.path.length is 1
          # Position the avatar directly to the (empty space) end point.
          physicsObject.setPosition movement.pathSegment.end

          # Notify that the movement has completed.
          movement.options.onCompleted?()

        # Remove this path segment.
        movement.pathSegment = null
        movement.path.shift()

    # Remove all movements that have completed.
    _.remove @_movements, (movement) => movement.path.length is 0

    @spaceOccupation.debugUpdate appTime if @world.spaceOccupationDebug()
