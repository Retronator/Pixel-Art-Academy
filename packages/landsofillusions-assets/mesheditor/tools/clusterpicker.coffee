AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.ClusterPicker extends FM.Tool
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

    mesh = @options.editor().mesh()
    
    # See which cluster contains this pixel.
    cluster = _.find(mesh.clusters(), (cluster) => cluster.findPixelAtCoordinate @mouseState.x, @mouseState.y)
    @options.editor().currentCluster cluster

    return unless cluster
      
    pixel = cluster.pixels[0]
      
    if pixel.paletteColor
      @options.editor().palette().setColor pixel.paletteColor.ramp, pixel.paletteColor.shade
      
    else if pixel.materialIndex?
      @options.editor().materials().setIndex pixel.materialIndex

    if pixel.normal
      @options.editor().shadingSphere().setNormal pixel.normal
