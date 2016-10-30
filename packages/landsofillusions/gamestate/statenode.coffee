AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateNode
  constructor: (@options) ->
    @_instances = {}
    @_instancesUpdatedDependency = new Tracker.Dependency

    @state = new ReactiveField null

    # Instantiate state property objects.
    Tracker.autorun (computation) =>
      # Compare properties vs instances.
      instanceKeys = _.keys @_instances
      stateKeys = if @state() then _.keys @state() else []

      newKeys = _.difference stateKeys, instanceKeys
      retiredKeys = _.difference instanceKeys, stateKeys

      # Create new instances.
      for newKey in newKeys
        constructor = @options.class.getClassForID newKey
        instance = new constructor
          adventure: @options.adventure

        @_instances[newKey] = instance

        # Reactively send state updates to the new instance.
        instance._stateAutorun = Tracker.autorun (computation) =>
          instance.state @state()[newKey]

        # Add shorthand accessor.
        @[newKey] = @_instances[newKey]

      # Destroy retired instances.
      for retiredKey in retiredKeys
        @_instances[retiredKey].destroy()
        @_instances[retiredKey]._stateAutorun.stop()
        delete @_instances[retiredKey]
        delete @[retiredKey]

      @_instancesUpdatedDependency.changed()

  values: ->
    @_instancesUpdatedDependency.depend()
    _.values @_instances
