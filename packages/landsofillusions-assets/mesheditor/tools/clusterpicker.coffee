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
    cluster = _.find(mesh.clusters(), (cluster) => cluster.findPixelAtCoordinate @pixelCoordinate.x, @pixelCoordinate.y)

    currentClusterHelper = @interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.CurrentCluster
    currentClusterHelper.setCluster cluster

    return unless cluster

    pixel = cluster.pixels[0]
    paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

    if pixel.paletteColor
      paintHelper.setPaletteColor pixel.paletteColor

    else if pixel.directColor
      paintHelper.setDirectColor pixel.directColor

    else if pixel.materialIndex?
      paintHelper.setMaterialIndex pixel.materialIndex

    if pixel.normal
      paintHelper.setNormal pixel.normal
