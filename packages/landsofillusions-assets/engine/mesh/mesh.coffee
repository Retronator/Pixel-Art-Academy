LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh extends THREE.Object3D
  @debug = false
  
  constructor: (@options) ->
    super arguments...

    @clusters = new ReactiveField null
    @edges = new ReactiveField null

    # Add the object to the scene once it's ready.
    Tracker.autorun (computation) =>
      return unless scene = @options.sceneManager()?.scene()
      computation.stop()

      scene.add @

    # Generate cluster meshes.
    Tracker.autorun (computation) =>
      return unless meshData = @options.meshData()
      return unless cameraAngle = meshData.cameraAngles?[0]
      return unless cameraAngle.sprite

      clusters = @constructor.detectClusters cameraAngle.sprite
      edges = @constructor.computeEdges clusters if clusters

      @clusters clusters
      @edges edges

      return unless clusters?.length and edges

      @constructor.computeClusterPlanes clusters, cameraAngle

      edge.generateGeometry cameraAngle for edge in edges when edge.line.point

      @constructor.projectClusterPoints clusters, cameraAngle
      @constructor.computeClusterMeshes clusters

    # Update scene.
    Tracker.autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      clusters = @clusters()
      edges = @edges()

      return unless clusters?.length and edges

      debug = @options.debug()
      currentCluster = @options.currentCluster()

      # Add new children.
      for cluster in clusters
        # Do not draw unselected clusters in debug mode.
        if not debug or debug and (not currentCluster or cluster is currentCluster)
          continue unless mesh = cluster.getMesh @options
          @add mesh

          if debug
            mesh.layers.set 2

            points = cluster.getPoints @options
            points.layers.set 2
            @add points
      
      for edge in edges when edge.line.point
        edge.layers.set 2
        @add edge

      @options.sceneManager()?.scene.updated()
