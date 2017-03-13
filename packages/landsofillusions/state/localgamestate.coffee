AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.LocalGameState
  constructor: ->
    @state = new ReactiveField {}

    @_stateAutorun = AM.PersistentStorage.persist
      storageKey: "LandsOfIllusions.Adventure.state"
      field: @state

  destroy: ->
    @_stateAutorun.stop()

  updated: (options = {}) ->
    # Simply re-write the state into storage.
    @state @state()

    options.callback?()
