LOI = LandsOfIllusions

class LOI.Engine.RenderingSides
  @Keys:
    Front: 'front'
    FrontLeft: 'frontLeft'
    Left: 'left'
    BackLeft: 'backLeft'
    Back: 'back'
    BackRight: 'backRight'
    Right: 'right'
    FrontRight: 'frontRight'

  @angles:
    front: 0
    frontLeft: Math.PI / 4
    left: Math.PI / 2
    backLeft: Math.PI * 3 / 4
    back: Math.PI
    backRight: - Math.PI * 3 / 4
    right: -Math.PI / 2
    frontRight: -Math.PI / 4

  @mirrorSides:
    front: 'front'
    frontLeft: 'frontRight'
    left: 'right'
    backLeft: 'backRight'
    back: 'back'
    backRight: 'backLeft'
    right: 'left'
    frontRight: 'frontLeft'

  @getAngleForDirection: (direction) ->
    # Angle 0 is pointing towards the camera (positive Z direction).
    -Math.atan2 direction.x, direction.z

  @getSideForDirection: (direction) ->
    @getSideForAngle @getAngleForDirection direction

  @getSideForAngle: (angle) ->
    closestSide = null
    closestSideDistance = Number.POSITIVE_INFINITY

    for side, sideAngle of @angles
      distance = _.angleDistance angle, sideAngle

      if distance < closestSideDistance
        closestSideDistance = distance
        closestSide = side

    closestSide
