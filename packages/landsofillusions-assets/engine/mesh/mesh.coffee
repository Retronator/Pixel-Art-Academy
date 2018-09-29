LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh extends THREE.Object3D
  @debug = false
  
  constructor: (@options) ->
    super

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

      # Place the plane of the cluster under the Origin landmark to the coordinate system origin.
      origin = _.find cameraAngle.sprite.landmarks, (landmark) => landmark.name is 'Origin'

      # If no Origin landmark is found, use the world origin.
      origin ?= cameraAngle.unprojectPoint new THREE.Vector3

      if originCluster = _.find(clusters, (cluster) => cluster.findPixelAtCoordinate origin.x, origin.y)
        originCluster.plane.point = new THREE.Vector3

        # Compute planes for all cluster adjacent to the origin cluster.
        @constructor.computeClusterPlanes originCluster, cameraAngle

      # Now compute planes for all free-floating clusters as well.
      for cluster in clusters when not cluster.plane.point
        # Assume the cluster is in the origin plane.
        cluster.plane.point = new THREE.Vector3
        @constructor.computeClusterPlanes cluster, cameraAngle

      edge.generateGeometry cameraAngle for edge in edges when edge.line.point

      @constructor.projectClusterPoints clusters, cameraAngle
      @constructor.computeClusterMeshes clusters

    # Update scene.
    Tracker.autorun (computation) =>
      return unless meshData = @options.meshData()
      return unless cameraAngle = meshData.cameraAngles?[0]

      # Clean up previous children.
      @remove @children[0] while @children.length

      clusters = @clusters()
      edges = @edges()

      return unless clusters?.length and edges

      # Add new children.
      for cluster in clusters
        @add cluster.getMesh @options

        points = cluster.getPoints()
        points.layers.set 2
        @add points
      
      for edge in edges when edge.line.point
        edge.layers.set 2
        @add edge

      @options.sceneManager().scene.updated()
