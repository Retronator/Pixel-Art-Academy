FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.CurrentCluster extends FM.Helper
  # objectIndex: index of the object for this cluster
  # clusterId: ID of the cluster within the object
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.CurrentCluster'
  @initialize()
  
  constructor: ->
    super arguments...

    @cluster = new ComputedField =>
      objectIndex = @objectIndex()
      clusterId = @clusterId()
      return unless objectIndex? and clusterId?

      return unless meshLoader = @interface.getLoaderForFile @fileId
      return unless meshObject = meshLoader.meshData()?.objects.get objectIndex

      meshObject.clusters()[clusterId]

  clusterId: -> @data.get 'clusterId'
  setClusterId: (index) -> @data.set 'clusterId', index

  objectIndex: -> @data.get 'objectIndex'
  setObjectIndex: (index) -> @data.set 'objectIndex', index

  setCluster: (cluster) ->
    unless cluster
      @setClusterId null
      @setObjectIndex null
      return

    @setClusterId cluster.id

    object = cluster.layer.object
    @setObjectIndex object.index

  getSceneCluster: ->
    meshId = @cluster().layer.object.mesh._id
    sceneHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.Scene, meshId
    scene = sceneHelper.scene()

    scene.getObjectByProperty 'data', @cluster()
