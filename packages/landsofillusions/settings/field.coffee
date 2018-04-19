LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Settings.Field
  constructor: (defaultValue, name, persistDecision) ->
    storedValue = new ReactiveField defaultValue

    AM.PersistentStorage.persist
      field: storedValue
      storageKey: "LandsOfIllusions.Settings.#{name}"

    # Read initial values from local storage, if present.
    @value = new ReactiveField storedValue()

    # Update stored value.
    Tracker.autorun (computation) =>
      value = @value()

      # If we're not allowed to store the value, we set it to undefined, which will clear it from local storage.
      value = undefined unless persistDecision.allowed()

      storedValue value
