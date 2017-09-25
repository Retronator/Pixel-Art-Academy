AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  # Create global listeners.
  _initializeListeners: ->
    # Returns all active listeners.
    @currentListeners = new ComputedField =>
      _.flattenDeep [
        LOI.adventure.parser.listeners
        thing.listeners for thing in @currentThings()
      ]
      
  @initializeListenerProvider: (providerInstance) ->
    providerInstance.listeners = []
    for listenerClass in providerInstance.constructor.listeners()
      providerInstance.listeners.push new listenerClass
        parent: providerInstance

  @destroyListenerProvider: (providerInstance) ->
    listener.destroy() for listener in providerInstance.listeners
    providerInstance.listeners = []
