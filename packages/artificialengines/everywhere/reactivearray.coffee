AE = Artificial.Everywhere

# Caches an array returned from a reactive source and provides extra information about content changes.
class AE.ReactiveArray
  constructor: (sourceFunction, options = {}) ->
    reactiveArray = new ReactiveField []

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf reactiveArray, @constructor.prototype

    updateAutorun = Tracker.autorun (computation) ->
      oldItems = Tracker.nonreactive => reactiveArray()
      newItems = sourceFunction() or []
      reactiveArray newItems

      # Report changes.
      for item in newItems
        if item in oldItems
          options.updated? item

        else
          options.added? item

      for item in oldItems when not (item in newItems)
        options.removed? item

    reactiveArray.stop = ->
      updateAutorun.stop()

    return reactiveArray
