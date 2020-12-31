AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object extends AS.RenderObject
  constructor: (@mesh, @data) ->
    super arguments...
    
    # Note: We can't call these layers, since that's an Object3D rendering system.
    @engineLayers = new ComputedField =>
      return unless layersData = @data.layers.getAllWithoutUpdates()
      
      for layerData in layersData
        new @constructor.Layer @, layerData

    @ready = new ComputedField =>
      return unless layers = @engineLayers()

      for layer in layers
        return unless layer.ready()

      true

    @edgeLineSegments = new ReactiveField []

    @boundingBox = new ReactiveField null

    # Reposition the object so the origin is in the center of its bounding box.
    @autorun (computation) =>
      return unless layers = @engineLayers()

      # Calculate the bounding box.
      boundingBox = null

      for layer in layers
        continue unless layerBoundingBox = layer.boundingBox()

        if boundingBox
          boundingBox.union layerBoundingBox

        else
          boundingBox = layerBoundingBox

      @boundingBox boundingBox

      # Reposition object to bounding box center.
      boundingBox?.getCenter @position

      # Offset layers in the opposite direction.
      layer.position.copy(@position).negate() for layer in layers

      if @mesh.options.debug?()
        lineSegments.position.copy(@position).negate() for lineSegments in @edgeLineSegments()

    # Update object children.
    @autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      layers = @engineLayers()
      return unless layers?.length

      # Add new children.
      @add layer for layer in layers

      edgeLineSegments = []

      if @mesh.options.debug?()
        currentCluster = @mesh.options.currentCluster?()

        # Add edge lines.
        for edge in @data.solver.edges

          # Do not draw edges of unselected clusters in debug mode.
          continue if currentCluster and currentCluster not in [edge.clusterA.layerCluster, edge.clusterB.layerCluster]

          lineSegments = edge.getLineSegments @data.mesh.cameraAngles.get 0
          lineSegments.layers.set 2
          @add lineSegments

          lineSegments.position.copy(@position).negate()
          edgeLineSegments.push lineSegments

      @edgeLineSegments edgeLineSegments

      @mesh.options.sceneManager.addedSceneObjects()

    # Update visibility.
    @autorun (computation) =>
      # See if mesh object visibility is controlled externally.
      @visible = @mesh.options.objectVisibility? @data.name()

      # Default to object's visibility in the mesh file.
      @visible ?= @data.visible()

      @mesh.options.sceneManager.scene.updated()

  destroy: ->
    super arguments...

    layer.destroy() for layer in @engineLayers()
