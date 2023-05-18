ReactiveField::waitForValue = ->
  new Promise (resolve) =>
    Tracker.autorun (computation) =>
      return unless value = @()
      computation.stop()

      resolve value
