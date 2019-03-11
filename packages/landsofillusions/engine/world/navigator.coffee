AS = Artificial.Spectrum
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.Navigator
  constructor: (@world) ->
    @_movements = []

  moveRenderObject: (options) ->
    # Remove any existing movements for this render object.
    _.remove @_movements, (movement) => movement.options.renderObject is options.renderObject
      
    target = LOI.adventure.world.getPositionVector options.target
    path = [THREE.Vector3.fromObject target]

    movement = {options, path}
    @_movements.push movement

  update: (appTime) ->
    for movement in @_movements
      unless movement.pathSegment
        # Set the next path segment.
        start = movement.options.renderObject.position.clone()
        end = movement.path[0]
        movement.pathSegment = new THREE.Line3 start, end

        # Direct the object towards the segment end.
        movement.direction = new THREE.Vector3().subVectors end, start
        movement.direction.normalize()
        movement.options.renderObject.faceDirection? movement.direction

      # Move the object in the desired direction.
      distance = appTime.elapsedAppTime * movement.options.speed
      movement.options.renderObject.position.add movement.direction.clone().multiplyScalar distance

      # See if we've reached the end of the path segment.
      unless distance and movement.pathSegment.closestPointToPointParameter(movement.options.renderObject.position) < 1
        # See if this is the end of the path.
        if movement.path.length is 1
          # Position the object directly to the end point.
          movement.options.renderObject.position.copy movement.path[0]

          # Notify that the movement has completed.
          movement.options.onCompleted?()

        # Remove this path segment.
        movement.pathSegment = null
        movement.path.shift()

    # Remove all movements that have completed.
    _.remove @_movements, (movement) => movement.path.length is 0
