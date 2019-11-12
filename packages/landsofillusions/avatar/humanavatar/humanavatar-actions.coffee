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

  lookAt: (target) ->
    position = target.position
    position ?= target.getRenderObject?().position
    position ?= target.avatar?.getRenderObject?().position

    unless position
      console.warn "Look at position could not be determined."
      return

    @getRenderObject().facePosition position
