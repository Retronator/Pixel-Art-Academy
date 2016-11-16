AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateNode
  constructor: (options) ->
    instances = {}
    instancesUpdatedDependency = new Tracker.Dependency

    state = new ReactiveField null

    # We want the state node to behave as a function to which we pass an item ID of the instance we want.
    stateNode = (id) ->
      console.log "State node searching for id", id, instances[id] if LOI.debug
      instancesUpdatedDependency.depend()
      instances[id]

    stateNode.ready = new ReactiveField false

    # Allow correct handling of instanceof operator.
    if Object.setPrototypeOf
      Object.setPrototypeOf stateNode, @constructor::
    else
      stateNode.__proto__ = @constructor::

    # Instantiate state property objects.
    stateUpdatedAutorun = Tracker.autorun (computation) ->
      return unless state()

      # Compare properties vs instances.
      instanceKeys = _.keys instances
      stateKeys = _.keys state()

      newKeys = _.difference stateKeys, instanceKeys
      retiredKeys = _.difference instanceKeys, stateKeys

      console.log "State node is being updated with new keys", newKeys, "and removing keys", retiredKeys if LOI.debug

      # Create new instances.
      for newKey in newKeys
        constructor = LOI.Adventure.Thing.getClassForID newKey

        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        instance = null
        Tracker.nonreactive ->
          instance = new constructor options

        instances[newKey] = instance

        # Reactively send state updates to the new instance.
        instance._stateAutorun = Tracker.autorun (computation) ->
          instance.state state()[newKey]

      # Destroy retired instances.
      for retiredKey in retiredKeys
        instances[retiredKey].destroy?()
        instances[retiredKey]._stateAutorun.stop()
        delete instances[retiredKey]

      # Notify of the change if we had any new or removed instances.
      instancesUpdatedDependency.changed() if newKeys.length + retiredKeys.length

      # We've completed at least one initialization so we can mark the state node as ready.
      stateNode.ready true

    stateNode.destroy = ->
      stateUpdatedAutorun.stop()

    stateNode.updateState = (newState) ->
      state newState

    stateNode.values = ->
      instancesUpdatedDependency.depend()
      _.values instances

    # Return the state node getter function (return must be explicit).
    return stateNode
