LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture extends LOI.Assets.Mesh.Object.Layer.Picture
  _recomputeClusters: (addList, removeList) ->
    console.log "Recomputing clusters in picture", @, addList, removeList if @constructor.debug

    changedClusters = {}

    if @_bounds
      width = @_bounds.width
      height = @_bounds.height

      unless @_clusterRecomputeMask?.length is @_bounds.width * @_bounds.height
        @_clusterRecomputeMask = new Uint8Array @_bounds.width * @_bounds.height

      if clusterIdMap = @maps.clusterId
        # We only need to recompute changed clusters.
        @_clusterRecomputeMask.fill 0

        recomputeCluster = (clusterId) =>
          return if changedClusters[clusterId]

          changedClusters[clusterId] = @clusters[clusterId].properties

          # Add cluster's mask to recompute mask.
          for i in [0...@_clusterRecomputeMask.length]
            @_clusterRecomputeMask[i] = 1 if clusterIdMap.idData[i] is clusterId

        # Mark all clusters with removed pixels for recomputation.
        for pixel in removeList
          clusterId = clusterIdMap.getPixel pixel.relativeX, pixel.relativeY

          # Mark cluster for recomputation.
          recomputeCluster clusterId

        for pixel in addList
          # Mark pixel for recomputation.
          @_clusterRecomputeMask[pixel.relativeX + pixel.relativeY * width] = 1

          # See if the added pixel matches any neighbors.
          for xOffset in [-1..1]
            neighborX = pixel.relativeX + xOffset
            continue unless 0 <= neighborX < width

            for yOffset in [-1..1 ]
              continue unless xOffset or yOffset

              neighborY = pixel.relativeY + yOffset
              continue unless 0 <= neighborY < height

              continue unless @maps.flags.pixelExists neighborX, neighborY

              # See if the neighbor belongs to the same cluster.
              same = true

              for mapType, value of pixel.properties
                if map = @maps[mapType]
                  same = map.pixelsAreSame pixel.relativeX, pixel.relativeY, neighborX, neighborY

                else
                  same = value is null

                # Stop checking values when we find a difference.
                break unless same

              # If neighbor is different, this pixel won't affect its cluster.
              continue unless same

              # Neighbor's cluster matches and so will need to be recomputed.
              neighborClusterId = clusterIdMap.getPixel neighborX, neighborY

              # Note: Neighbor might not have been assigned to a cluster yet when adding multiple pixels.
              recomputeCluster neighborClusterId if neighborClusterId

      else
        # We don't have a cluster map yet, so we need to do a full recomputation.
        @_clusterRecomputeMask.fill 1

      # Detect clusters within the new recomputation mask.
      detectedClusters = @_detectClusters()
      
      # Match detected clusters to existing ones.
      @_matchDetectedClusters detectedClusters, changedClusters
        
    else
      # Since there are no more bounds, all existing clusters were removed from this picture.
      for id, cluster of @clusters
        cluster.remove()
