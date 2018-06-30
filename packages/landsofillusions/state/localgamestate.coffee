AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.LocalGameState
  constructor: ->
    @state = new ReactiveField {}

    @_stateAutorun = AM.PersistentStorage.persist
      storageKey: "LandsOfIllusions.Adventure.state"
      field: @state
      consentField: LOI.settings.persistGameState.allowed

  destroy: ->
    @_stateAutorun.stop()

  updated: (options = {}) ->
    # Simply re-write the state into storage.
    @state @state()

    options.callback?()

  resetNamespaces: (namespaces) ->
    state = @state()

    for namespace in namespaces
      _.nestedProperty state.things, namespace, {}
      _.nestedProperty state.scripts, namespace, {}

    @state state
