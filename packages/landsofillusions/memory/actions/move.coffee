LOI = LandsOfIllusions
AM = Artificial.Mummification

Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Actions.Move extends LOI.Memory.Action
  # content:
  #   landmark: the named point that can be looked up to get its coordinates
  #   coordinates: direct location coordinates, if landmark is not specified
  #     x, y, z
  @type: 'LandsOfIllusions.Memory.Actions.Move'
  @register @type, @

  @registerContentPattern @type, Match.OptionalOrNull
    landmark: Match.Optional String
    coordinates: Match.Optional
      x: Number
      y: Number
      z: Number

  @retainDuration: -> 60 # seconds

  @startDescription: ->
    "_person_ enters."

  createStartScript: (person, nextNode, nodeOptions = {}) ->
    renderObject = person.avatar.getRenderObject()
    physicsObject = person.avatar.getPhysicsObject()

    if @content?.coordinates
      renderObject.setAnimation 'Walk 50'
      physicsObject.setMass physicsObject.walkMass

      LOI.adventure.world.navigator().moveAvatar
        avatar: person.avatar
        target: @content.coordinates
        speed: 1.25
        onCompleted: =>
          renderObject.setAnimation 'Idle loop'
          physicsObject.setMass physicsObject.idleMass

    null
