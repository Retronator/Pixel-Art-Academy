AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Object.Layer extends AS.RenderObject
  constructor: (@object, @data) ->
    super arguments...

    @isLayer = true
    @isRenderable = not _.startsWith @data.name()?.toLowerCase(), 'hint'

    @clusters = new ComputedField =>
      return unless clustersData = @data.clusters.getAllWithoutUpdates()

      for clusterId, clusterData of clustersData
        new @constructor.Cluster @, clusterData

    @ready = new ComputedField =>
      return unless clusters = @clusters()

      for cluster in clusters
        return unless cluster.ready()

      true

    @boundingBox = new ComputedField =>
      return unless clusters = @clusters()

      boundingBox = null

      for cluster in clusters
        continue unless clusterBoundingBox = cluster.boundingBox()

        if boundingBox
          boundingBox.union clusterBoundingBox

        else
          boundingBox = clusterBoundingBox

      boundingBox

    # Update object children.
    @autorun (computation) =>
      # Clean up previous children.
      @remove @children[0] while @children.length

      clusters = @clusters()
      return unless clusters?.length

      debug = @object.mesh.options.debug?()
      currentCluster = @object.mesh.options.currentCluster?()

      # Add new children.
      for cluster in clusters
        # Do not draw unselected clusters in debug mode.
        continue if debug and currentCluster and currentCluster isnt cluster.data

        @add cluster

      @object.mesh.options.sceneManager.addedSceneObjects()

    # Update visibility.
    @autorun (computation) =>
      @visible = @data.visible()

      @object.mesh.options.sceneManager.scene.updated()

  destroy: ->
    super arguments...

    cluster.destroy() for cluster in @clusters()
