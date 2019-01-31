LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object extends THREE.Object3D
  constructor: (@mesh, objectData) ->
    super arguments...

    @clusters = new ReactiveField null
    @edges = new ReactiveField null

    # Generate cluster meshes.
    Tracker.autorun (computation) =>
      clusters = @constructor.detectClusters objectData
      edges = @constructor.computeEdges clusters if clusters

      @clusters clusters
      @edges edges

      return unless clusters?.length and edges

      cameraAngle = objectData.mesh.cameraAngles.get 0
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

      debug = @mesh.options.debug?()
      currentCluster = @mesh.options.currentCluster()

      # Add new children.
      for cluster in clusters
        # Do not draw unselected clusters in debug mode.
        if not debug or debug and (not currentCluster or cluster is currentCluster)
          continue unless mesh = cluster.getMesh @mesh.options
          @add mesh

          if debug
            mesh.layers.set 2

            points = cluster.getPoints @mesh.options
            points.layers.set 2
            @add points
      
      for edge in edges when edge.line.point
        edge.layers.set 2
        @add edge

      @mesh.options.sceneManager()?.scene.updated()
