AS = Artificial.Spectrum

class AS.RenderObject extends THREE.Object3D
  constructor: ->
    super

    # Provides support for autorun calls that stop when render object is destroyed.
    @_autorunHandles = []

  destroy: ->
    handle.stop() for handle in @_autorunHandles

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle
