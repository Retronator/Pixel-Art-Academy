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
      return unless cameraAngle = meshData.cameraAngles[0]

      return unless clusters = @constructor.detectClusters cameraAngle.sprite
      @clusters clusters

      return unless edges = @constructor.computeEdges clusters
      @edges edges

      # Place the plane of the cluster under the Origin landmark to the coordinate system origin.
      origin = _.find cameraAngle.sprite.landmarks, (landmark) => landmark.name is 'Origin'
      originCluster = _.find clusters, (cluster) => cluster.findPixelAtCoordinate origin.x, origin.y
      originCluster.plane.point = new THREE.Vector3

      @constructor.computeClusterPlanes clusters, originCluster, edges, cameraAngle
      @constructor.projectClusterPoints clusters, cameraAngle
      return unless clusterMeshes = @constructor.computeClusterMeshes clusters, edges

      # Replace children.
      @remove @children[0] while @children.length
      @add clusterMeshes... if clusterMeshes.length

      for cluster in clusters
        @add cluster.getPoints()
      
      for edge in edges when edge.line.point
        edge.generateGeometry cameraAngle
        @add edge

      @options.sceneManager().scene.updated()
