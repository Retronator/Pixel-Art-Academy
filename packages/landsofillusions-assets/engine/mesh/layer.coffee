LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Layer extends THREE.Object3D
  constructor: (@object, layerData) ->
    super arguments...
    
    @clusters = new ComputedField =>
      return unless clustersData = layerData.clusters.getAllWithoutUpdates()

      for clusterId, clusterData of clustersData
        new @constructor.Cluster @, clusterData

    # Update object children.
    Tracker.autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      clusters = @clusters()
      return unless clusters?.length

      debug = @object.mesh.options.debug?()
      currentCluster = @object.mesh.options.currentCluster?()

      # Add new children.
      for cluster in clusters
        # Do not draw unselected clusters in debug mode.
        continue if debug and currentCluster and currentCluster isnt cluster.clusterData

        @add cluster

      @object.mesh.options.sceneManager.addedSceneObjects()

    # Update visibility.
    Tracker.autorun (computation) =>
      @visible = layerData.visible()

      @object.mesh.options.sceneManager.scene.updated()
