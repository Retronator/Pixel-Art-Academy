AM = Artificial.Mirage
FM = FataMorgana

class FM.Loader
  constructor: (@interface, @fileId) ->
    # Provide support for autorun calls that stop when operator is destroyed.
    @_autorunHandles = []

  destroy: ->
    handle.stop() for handle in @_autorunHandles

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle
