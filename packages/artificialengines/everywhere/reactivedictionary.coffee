AE = Artificial.Everywhere

# Caches an object returned from a reactive source and provides extra information about field changes.
class AE.ReactiveDictionary
  constructor: (sourceFunction, options = {}) ->
    reactiveDictionary = new ReactiveField {}

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf reactiveDictionary, @constructor.prototype

    updateAutorun = Tracker.autorun (computation) ->
      oldDictionary = Tracker.nonreactive => reactiveDictionary()
      newDictionary = sourceFunction() or {}
      reactiveDictionary newDictionary

      # Report changes.
      for key, value of newDictionary
        if oldDictionary[key]?
          options.updated? key, value, oldDictionary[key]

        else
          options.added? key, value

      for key, value of oldDictionary when not newDictionary[key]?
        options.removed? key, value

    reactiveDictionary.stop = ->
      # Prevent multiple calls to stop.
      return unless updateAutorun
      
      updateAutorun.stop()
      updateAutorun = null
    
      # Remove all remaining entries.
      if options.removed
        for key, value of reactiveDictionary()
          options.removed key, value
      
      reactiveDictionary {}
    
    return reactiveDictionary
