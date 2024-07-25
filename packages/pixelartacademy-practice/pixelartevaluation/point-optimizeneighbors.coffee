AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Point.optimizeNeighbors = (points) ->
  for rootPoint in points
    # Eliminate triangles by removing the longer sides.
    loop
      eliminated = false
      
      for neighborA in rootPoint.neighbors
        distanceA = rootPoint._distanceTo neighborA
  
        for neighborB in rootPoint.neighbors when neighborB isnt neighborA and neighborB in neighborA.neighbors
          distanceB = rootPoint._distanceTo neighborB
          distanceC = neighborA._distanceTo neighborB
          
          if distanceC > distanceA and distanceC > distanceB
            eliminatingPointA = neighborA
            eliminatingPointB = neighborB
            outsidePoint = rootPoint
            
          else
            eliminatingPointA = rootPoint
            eliminatingPointB = if distanceA > distanceB then neighborA else neighborB
            outsidePoint = if eliminatingPointB is neighborA then neighborB else neighborA
          
          # Do not remove outline edges if that would break the outline (the outside point is not on the outline).
          sharedOutlineCore = @getSharedOutlineCore eliminatingPointA, eliminatingPointB
          outsidePixel = outsidePoint.getOutlinePixel()
          continue if sharedOutlineCore and (not outsidePixel or sharedOutlineCore not in outsidePixel.outlineCores)
          
          eliminatingPointA._disconnectNeighbor eliminatingPointB
          eliminatingPointB._disconnectNeighbor eliminatingPointA
          
          eliminated = true
          break
          
        break if eliminated
        
      break unless eliminated
      
  # Eliminate non-outline connections between junctions (3 or more neighbors), since it's hard to determine meaningful
  # connectivity in that case. We need to first collect all connections and not remove them as we go along since that
  # would change their number of neighbors.
  eliminatedConnections = []
  
  for rootPoint in points when rootPoint.neighbors.length >= 3 and not rootPoint.getOutlinePixel()
    for neighbor in rootPoint.neighbors when neighbor.neighbors.length >= 3
      eliminatedConnections.push [rootPoint, neighbor]
  
  # Eliminate core extensions (short lines sticking out of cores, which should
  # be part of core outlines if we had better filtering when eliminating triangles).
  for rootPoint in points when rootPoint.getOutlinePixel()
    for neighbor in rootPoint.neighbors when neighbor.neighbors.length is 1
      eliminatedConnections.push [rootPoint, neighbor]
  
  for [neighborA, neighborB] in eliminatedConnections
    neighborA._disconnectNeighbor neighborB
    neighborB._disconnectNeighbor neighborA
  
  # On outlines, make sure there are exactly two neighbors for each outline.
  for rootPoint in points
    continue unless outlinePixel = rootPoint.getOutlinePixel()
  
    for outlineCore, index in outlinePixel.outlineCores
      outlineNeighbors = _.filter rootPoint.neighbors, (neighbor) =>
        return unless neighborOutlinePixel = neighbor.getOutlinePixel()
        outlineCore in neighborOutlinePixel.outlineCores
    
      continue if outlineNeighbors.length is 2
      
      if outlineNeighbors.length < 2
        console.error "Outline point didn't have 2 neighbors.", rootPoint
        continue
      
      if rootPoint.pixels.length > 1
        console.error "Outline point has multiple pixels", rootPoint
        continue
      
      # Remove outline bridge edges (outer lines connecting two parts of the outline on different
      # areas of the core). We do this first to prevent unnecessary inner edge removals.
      for neighbor in outlineNeighbors
        # We must have at least one core pixel neighbor in common, otherwise this is a bridge.
        sharedCorePixelFound = false
        
        if neighbor.pixels.length > 1
          console.error "Neighboring outline point has multiple pixels", neighbor
          continue
          
        neighborOutlinePixel = neighbor.pixels[0]
        
        for x in [neighborOutlinePixel.x - 1..neighborOutlinePixel.x + 1] when outlinePixel.x - 1 <= x <= outlinePixel.x + 1
          for y in [neighborOutlinePixel.y - 1..neighborOutlinePixel.y + 1] when outlinePixel.y - 1 <= y <= outlinePixel.y + 1
            if rootPoint.layer.getPixel(x, y)?.core
              sharedCorePixelFound = true
              break
          break if sharedCorePixelFound
        continue if sharedCorePixelFound
        
        rootPoint._disconnectNeighbor neighbor
        neighbor._disconnectNeighbor rootPoint
        
  for rootPoint in points
    # Test if we still have more than 2 neighbors on the same outline.
    continue unless outlinePixel = rootPoint.getOutlinePixel()
    
    for outlineCore, index in outlinePixel.outlineCores
      outlineNeighbors = _.filter rootPoint.neighbors, (neighbor) =>
        return unless neighborOutlinePixel = neighbor.getOutlinePixel()
        outlineCore in neighborOutlinePixel.outlineCores
        
      continue if outlineNeighbors.length is 2
      
      # Remove inner core edges (diagonals connecting two parts of the outline on different sides of the core).
      for neighbor in outlineNeighbors
        # We must have at least one outside pixel neighbor in common, otherwise this is an inner edge.
        sharedNonClusterPixelFound = false
        
        if neighbor.pixels.length > 1
          console.error "Neighboring outline point has multiple pixels", neighbor
          continue
          
        neighborOutlinePixel = neighbor.pixels[0]
        
        for x in [neighborOutlinePixel.x - 1..neighborOutlinePixel.x + 1] when outlinePixel.x - 1 <= x <= outlinePixel.x + 1
          for y in [neighborOutlinePixel.y - 1..neighborOutlinePixel.y + 1] when outlinePixel.y - 1 <= y <= outlinePixel.y + 1
            if pixel = rootPoint.layer.getPixel x, y
              unless pixel.core or outlineCore in pixel.outlineCores
                sharedNonClusterPixelFound = true
                break
            
            else
              sharedNonClusterPixelFound = true
              break
          break if sharedNonClusterPixelFound
        continue if sharedNonClusterPixelFound
        
        rootPoint._disconnectNeighbor neighbor
        neighbor._disconnectNeighbor rootPoint
        
  # Explicit return to avoid result collection.
  return
