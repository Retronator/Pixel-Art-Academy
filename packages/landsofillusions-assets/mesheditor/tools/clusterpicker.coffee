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

    mesh = @editor().mesh()
    
    # See which cluster contains this pixel.
    for object in mesh.objects()
      cluster = _.find(object.clusters(), (cluster) => cluster.findPixelAtAbsoluteCoordinate @pixelCoordinate.x, @pixelCoordinate.y)

    currentClusterHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CurrentCluster
    currentClusterHelper.setCluster cluster

    return unless cluster

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
