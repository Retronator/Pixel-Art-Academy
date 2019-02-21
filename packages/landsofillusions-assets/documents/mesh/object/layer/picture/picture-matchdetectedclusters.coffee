LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture extends LOI.Assets.Mesh.Object.Layer.Picture
  _matchDetectedClusters: (detectedClusters, existingClusters) ->
    console.log "Matching clusters in picture", @, _.cloneDeep(detectedClusters), _.cloneDeep(existingClusters) if @constructor.debug

    mapping = {}

    width = @_bounds.width
    height = @_bounds.height
    arrayLength = width * height

    clusterIdMap = @getMap @constructor.Map.Types.ClusterId

    for detectedClusterIndexString, detectedCluster of detectedClusters
      detectedClusterIndex = parseInt detectedClusterIndexString

      for existingClusterIdString, existingCluster of existingClusters
        # See if properties match.
        continue unless _.isEqual existingCluster, detectedCluster

        # See if pixels overlap.
        existingClusterId = parseInt existingClusterIdString

        # Traverse across detected pixel.
        for index in [0...arrayLength]
          continue unless @_detectedClusters[index] is detectedClusterIndex
          continue unless clusterIdMap.idData[index] is existingClusterId

          # Match was found! Add this mapping.
          mapping[detectedClusterIndex] =
            clusterId: existingClusterId
            sourceCoordinates: @getAbsoluteCoordinates
              x: index % width
              y: Math.floor index / width

          break

        # Stop searching after mapping was found.
        break if mapping[detectedClusterIndex]

      # If no match was found, map to a new cluster
      unless mapping[detectedClusterIndexString]
        # Use the first pixel of the cluster as the source position.
        for index in [0...arrayLength]
          continue unless @_detectedClusters[index] is detectedClusterIndex

          mapping[detectedClusterIndexString] =
            clusterId: @layer.object.generateNewClusterId()
            sourceCoordinates: @getAbsoluteCoordinates
              x: index % width
              y: Math.floor index / width

          break

    console.log "Created mapping", mapping if @constructor.debug

    # Apply the mapping.
    added = []
    updated = []
    removed = []

    for detectedClusterIndexString, match of mapping
      clusterId = match.clusterId
      newClusterData = sourceCoordinates: match.sourceCoordinates

      # See if this mapping goes to an existing cluster.
      if @clusters[clusterId]
        # See if we haven't used this cluster yet to map.
        if existingClusters[clusterId]
          # Mark that we've used this cluster.
          delete existingClusters[clusterId]

          # Instruct the cluster to update using new coordinates
          @clusters[clusterId].updateSourceCoordinates match.sourceCoordinates

          updated.push clusterId

        else
          # We can't map to this cluster anymore, so create a duplicate and replace its id.
          clusterId = @layer.object.generateNewClusterId()

          @clusters[clusterId] = new @constructor.Cluster @, clusterId, newClusterData

          @layer.duplicateCluster match.clusterId, clusterId

          # Replace the cluster ID in the match.
          match.clusterId = clusterId

          added.push clusterId

      else
        # This is a completely new cluster.
        @clusters[clusterId] = new @constructor.Cluster @, clusterId, newClusterData

        @layer.newCluster clusterId, @clusters[clusterId].properties

        added.push clusterId
        
    # Existing clusters that haven't been used have been deleted.
    for existingClusterIdString, existingCluster of existingClusters
      cluster = @clusters[existingClusterIdString]
      delete @clusters[existingClusterIdString]

      @layer.removeCluster cluster.id

      removed.push cluster.id

    # Update cluster map.
    for index in [0...arrayLength] when @_clusterRecomputeMask[index]
      detectedClusterIndex = @_detectedClusters[index]
      clusterIdMap.idData[index] = mapping[detectedClusterIndex]?.clusterId or 0

    # Update solver.
    @layer.object.solver?.update added, updated, removed

    # Signal that picture has updated.
    @contentUpdated()
