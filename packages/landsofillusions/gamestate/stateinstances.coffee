AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateInstances
  constructor: (options) ->
    options.classProvider ?= LOI.Adventure.Thing
    instances = {}
    instancesUpdatedDependency = new Tracker.Dependency

    if options.state
      stateGetter = options.state

    else
      stateGetter = new LOI.StateObject options

    # We want the state node to behave as a function to which we pass an item ID of the instance we want.
    stateInstances = (classOrId) ->
      id = _.thingId classOrId
      console.log "State node searching for id", id, instances[id] if LOI.debug
      instancesUpdatedDependency.depend()
      instances[id]

    stateInstances.ready = new ReactiveField false

    # Allow correct handling of instanceof operator.
    if Object.setPrototypeOf
      Object.setPrototypeOf stateInstances, @constructor::
    else
      stateInstances.__proto__ = @constructor::

    # Instantiate state property objects.
    stateUpdatedAutorun = Tracker.autorun (computation) ->
      newState = stateGetter()
      return unless newState

      # Compare properties vs instances.
      instanceKeys = _.keys instances

      if _.isArray newState
        stateKeys = for thing in newState
          _.thingId thing

      else if _.isObject newState
        stateKeys = _.keys newState

      else
        stateKeys = []

      newKeys = _.difference stateKeys, instanceKeys
      retiredKeys = _.difference instanceKeys, stateKeys

      console.log "State node is being updated with new keys", newKeys, "and removing keys", retiredKeys if LOI.debug

      # Create new instances.
      for newKey in newKeys
        constructor = options.classProvider.getClassForId newKey

        unless constructor
          console.error "Invalid thing with key", newKey, "in state node", stateInstances
          continue

        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        instance = null
        Tracker.nonreactive ->
          instance = new constructor options

        instances[newKey] = instance

      # Destroy retired instances.
      for retiredKey in retiredKeys
        instances[retiredKey].destroy?()
        delete instances[retiredKey]

      console.log "New state node instances are", instances if LOI.debug

      # Notify of the change if we had any new or removed instances.
      instancesUpdatedDependency.changed() if newKeys.length + retiredKeys.length

      # We've completed at least one initialization so we can mark the state node as ready.
      stateInstances.ready true

    stateInstances.destroy = ->
      stateUpdatedAutorun.stop()

    stateInstances.values = ->
      instancesUpdatedDependency.depend()
      _.values instances

    # Return the state node getter function (return must be explicit).
    return stateInstances
