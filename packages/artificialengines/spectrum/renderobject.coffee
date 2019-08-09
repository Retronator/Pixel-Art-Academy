AS = Artificial.Spectrum

class AS.RenderObject extends THREE.Object3D
  constructor: ->
    super arguments...

    # Provides support for autorun calls that stop when render object is destroyed.
    @_autorunHandles = []

  destroy: ->
    handle.stop() for handle in @_autorunHandles

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  scene: ->
    # Travel up the hierarchy until you hit an instance of a scene.
    ancestor = @

    while ancestor
      return ancestor if ancestor instanceof THREE.Scene
      ancestor = ancestor.parent

    # The object is not nested within a scene.
    null
