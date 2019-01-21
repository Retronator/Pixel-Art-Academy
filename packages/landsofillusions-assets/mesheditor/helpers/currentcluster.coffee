FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.CurrentCluster extends FM.Helper
  # index value of the cluster
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.CurrentCluster'
  @initialize()
  
  constructor: ->
    super arguments...

    @cluster = new ComputedField =>
      return unless meshLoader = @interface.getLoaderForFile @fileId
      return unless clusters = meshLoader.mesh.clusters()
      
      clusterIndex = @clusterIndex()
      clusters[clusterIndex]

  clusterIndex: -> @data.value()
  setClusterIndex: (index) -> @data.value index

  setCluster: (cluster) ->
    meshLoader = @interface.getLoaderForFile @fileId
    clusters = meshLoader.mesh.clusters()

    clusterIndex = clusters.indexOf cluster
    @setClusterIndex if clusterIndex >= 0 then clusterIndex else null
