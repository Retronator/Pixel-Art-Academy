LOI = LandsOfIllusions

_defaultColor = "#4c88bc"
_cleanedColor = "#bc544c"
_cleanupColor = "#4cbc66"

class LOI.Assets.MeshEditor.MeshCanvas.EdgePixels
  constructor: (@meshCanvas) ->
    
  drawToContext: (context) ->
    return unless @meshCanvas.edgePixelsEnabled()
    return unless objects = @meshCanvas.meshData()?.objects.getAll()

    context.lineWidth = 0.1

    currentClusterHelper = @meshCanvas.currentClusterHelper()
    currentCluster = currentClusterHelper.cluster()

    for object in objects
      # When we picked a cluster, only draw edge pixels of that object.
      continue if currentCluster and currentCluster.layer.object isnt object

      for edge in object.solver.edges
        # When we picked a cluster, only draw edge pixels of that cluster.
        continue if currentCluster and currentCluster not in [edge.clusterA.layerCluster, edge.clusterB.layerCluster]
        
        if currentCluster
          clusters = [if edge.clusterA.layerCluster is currentCluster then edge.clusterA else edge.clusterB]
          
        else
          clusters = [edge.clusterA, edge.clusterB]
        
        for cluster in clusters
          if cluster.cleanupPixels
            context.strokeStyle = if currentCluster then _cleanupColor else _defaultColor
            for pixel in cluster.cleanupPixels
              @_drawPixel context, pixel

          if cluster.cleanedPixels
            context.strokeStyle = if currentCluster then _cleanedColor else _defaultColor
            for pixel in cluster.cleanedPixels
              @_drawPixel context, pixel

  _drawPixel: (context, pixel) ->
    context.beginPath()
  
    context.moveTo pixel.x, pixel.y
    context.lineTo pixel.x + 1, pixel.y
    context.lineTo pixel.x + 1, pixel.y + 1
    context.lineTo pixel.x, pixel.y + 1
    context.lineTo pixel.x, pixel.y
  
    context.stroke()
