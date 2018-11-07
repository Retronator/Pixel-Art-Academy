AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Tools.ClusterPicker extends LandsOfIllusions.Assets.Tools.Tool
  constructor: ->
    super arguments...

    @name = "Cluster picker"
    @shortcut = AC.Keys.i
    @holdShortcut = AC.Keys.alt

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
