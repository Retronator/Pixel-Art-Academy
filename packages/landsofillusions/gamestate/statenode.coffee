AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateNode
  constructor: (@options) ->
    @_instances = {}
    @_instancesUpdatedDependency = new Tracker.Dependency

    @_state = new ReactiveField null

    # Instantiate state property objects.
    Tracker.autorun (computation) =>
      # Compare properties vs instances.
      instanceKeys = _.keys @_instances
      stateKeys = if @_state() then _.keys @_state() else []

      newKeys = _.difference stateKeys, instanceKeys
      retiredKeys = _.difference instanceKeys, stateKeys

      console.log "State node is being updated with new keys", newKeys, "and removing keys", retiredKeys if LOI.debug

      # Create new instances.
      for newKey in newKeys
        constructor = @options.class.getClassForID newKey

        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        instance = null
        Tracker.nonreactive =>
          instance = new constructor
            adventure: @options.adventure

        @_instances[newKey] = instance

        # Reactively send state updates to the new instance.
        instance._stateAutorun = Tracker.autorun (computation) =>
          instance.state @_state()[newKey]

        # Add shorthand accessor.
        @[newKey] = @_instances[newKey]

      # Destroy retired instances.
      for retiredKey in retiredKeys
        @_instances[retiredKey].destroy?()
        @_instances[retiredKey]._stateAutorun.stop()
        delete @_instances[retiredKey]
        delete @[retiredKey]

      # Notify of the change if we had any new or removed instances.
      @_instancesUpdatedDependency.changed() if newKeys.length + retiredKeys.length

  updateState: (state) ->
    @_state state

  values: ->
    @_instancesUpdatedDependency.depend()
    _.values @_instances
