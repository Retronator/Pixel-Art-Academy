LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object extends THREE.Object3D
  constructor: (@mesh, objectData) ->
    super arguments...
    
    # Note: We can't call these layers, since that's an Object3D rendering system.
    @engineLayers = new ComputedField =>
      return unless layersData = objectData.layers.getAllWithoutUpdates()
      
      for layerData in layersData
        new @constructor.Layer @, layerData

    # Update object children.
    Tracker.autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      layers = @engineLayers()
      return unless layers?.length

      # Add new children.
      @add layer for layer in layers

      @mesh.options.sceneManager.scene.updated()

    # Update visibility.
    Tracker.autorun (computation) =>
      @visible = objectData.visible()

      @mesh.options.sceneManager.scene.updated()
