AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.ClusterPicker extends LOI.Assets.MeshEditor.Tools.Tool
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.ClusterPicker'
  @displayName: -> "Cluster picker"

  @initialize()

  onMouseDown: (event) ->
    super arguments...

    @pickCluster()

  onMouseMove: (event) ->
    super arguments...

    @pickCluster()

  pickCluster: ->
    return unless @mouseState.leftButton

    currentClusterHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CurrentCluster
    currentCluster = currentClusterHelper.cluster()

    mesh = @editor().mesh()

    # See which clusters contain this pixel.
    clusters = _.flatten(
      for object in mesh.objects()
        _.filter(object.clusters(), (cluster) => cluster.findPixelAtAbsoluteCoordinate @pixelCoordinate.x, @pixelCoordinate.y)
    )

    # Reset selection when picked clusters change.
    @_clusterIndex = 0 if _.xor(clusters, @_previousClusters).length

    # If we have more than one choice, move to the next one that isn't selected yet.
    if clusters.length > 1
      @_clusterIndex++ while clusters[@_clusterIndex % clusters.length] is currentCluster

    cluster = clusters[@_clusterIndex % clusters.length]
    @_previousClusters = clusters
    currentClusterHelper.setCluster cluster

    return unless cluster

    console.log "Picked cluster", cluster if LOI.Assets.Engine.Mesh.debug

    properties = cluster.pixelProperties
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    if properties.paletteColor
      paintHelper.setPaletteColor properties.paletteColor

    else if properties.directColor
      paintHelper.setDirectColor properties.directColor

    else if properties.materialIndex?
      paintHelper.setMaterialIndex properties.materialIndex

    if properties.normal
      paintHelper.setNormal properties.normal

    paintHelper.setLayerIndex cluster.picture.layer.index
