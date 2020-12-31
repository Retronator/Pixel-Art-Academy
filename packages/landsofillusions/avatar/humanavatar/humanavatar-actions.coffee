AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.HumanAvatar extends LOI.HumanAvatar
  walkTo: (options) ->
    renderObject = @getRenderObject()
    physicsObject = @getPhysicsObject()

    renderObject.setAnimation 'Walk 50'
    physicsObject.setMass physicsObject.walkMass

    LOI.adventure.world.navigator().moveAvatar
      avatar: @
      target: options.target
      speed: 1.25
      onCompleted: =>
        renderObject.setAnimation 'Idle loop'
        physicsObject.setMass physicsObject.idleMass

        options.onCompleted?()

      onCanceled: =>
        # We need to inform the caller that the walking finished, even if it was canceled by the
        # navigator. We first see if a special callback was provided for handling canceled animations.
        if options.onCanceled?
          options.onCanceled()
          return

        # No special handler was found, default to completed.
        options.onCompleted?()

  lookAt: (positionOrTargetOrLandmark) ->
    if _.isString positionOrTargetOrLandmark
      # We have a landmark string.
      positionOrLandmark = positionOrTargetOrLandmark

    else if positionOrTargetOrLandmark.x and positionOrTargetOrLandmark.y and positionOrTargetOrLandmark.z
      # We have a vector position.
      positionOrLandmark = positionOrTargetOrLandmark

    else
      # We should have a target object/avatar/thing.
      target = positionOrTargetOrLandmark
      positionOrLandmark = target.position
      positionOrLandmark ?= target.getRenderObject?().position
      positionOrLandmark ?= target.avatar?.getRenderObject?().position

      unless positionOrLandmark
        console.warn "Look at position could not be determined from target", target
        return

    @getRenderObject().facePosition positionOrLandmark
