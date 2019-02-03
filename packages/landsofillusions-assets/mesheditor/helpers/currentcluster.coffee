FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.CurrentCluster extends FM.Helper
  # objectIndex: index of the object for this cluster
  # clusterIndex: index of the cluster within the object
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.CurrentCluster'
  @initialize()
  
  constructor: ->
    super arguments...

    @cluster = new ComputedField =>
      objectIndex = @objectIndex()
      clusterIndex = @clusterIndex()
      return unless objectIndex? and clusterIndex?

      return unless meshLoader = @interface.getLoaderForFile @fileId
      return unless meshObjects = meshLoader.mesh.objects()
      return unless clusters = meshObjects[objectIndex]?.clusters()
      
      clusters[clusterIndex]

  clusterIndex: -> @data.get 'clusterIndex'
  setClusterIndex: (index) -> @data.set 'clusterIndex', index

  objectIndex: -> @data.get 'objectIndex'
  setObjectIndex: (index) -> @data.set 'objectIndex', index

  setCluster: (cluster) ->
    unless cluster
      @setClusterIndex null
      @setObjectIndex null
      return

    object = cluster.picture.layer.object

    meshLoader = @interface.getLoaderForFile @fileId
    meshObjects = meshLoader.mesh.objects()
    clusters = meshObjects[object.index].clusters()

    clusterIndex = clusters.indexOf cluster
    @setClusterIndex clusterIndex
    @setObjectIndex object.index
