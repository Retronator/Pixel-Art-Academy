AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Point.optimizeNeighbors = (points) ->
  return unless points.length
  
  # Remove all long connections that span over two short connections.
  for rootPoint in points
    loop
      eliminated = false
      
      for neighborA in rootPoint.neighbors
        for neighborB in rootPoint.neighbors when neighborB isnt neighborA
          if rootPoint.x is (neighborA.x + neighborB.x) / 2 and rootPoint.y is (neighborA.y + neighborB.y) / 2
            eliminatingPoint1 = neighborA
            eliminatingPoint2 = neighborB
            
          else if neighborB.x is (rootPoint.x + neighborA.x) / 2 and neighborB.y is (rootPoint.y + neighborA.y) / 2
            eliminatingPoint1 = rootPoint
            eliminatingPoint2 = neighborA
            
          else if neighborA.x is (rootPoint.x + neighborB.x) / 2 and neighborA.y is (rootPoint.y + neighborB.y) / 2
            eliminatingPoint1 = rootPoint
            eliminatingPoint2 = neighborB
            
          else
            continue
          
          # Make sure the eliminating points are directly connected.
          continue unless eliminatingPoint1 in eliminatingPoint2.neighbors
          
          eliminatingPoint1._disconnectNeighbor eliminatingPoint2
          eliminatingPoint2._disconnectNeighbor eliminatingPoint1
          
          eliminated = true
          break
          
        break if eliminated
        
      break unless eliminated
      
  # Remove long diagonals that cross orthogonal connections.
  for rootPoint in points
    diagonalPoints = []
    
    for rootNeighbor in rootPoint.neighbors
      distance = rootPoint._distanceSquaredTo rootNeighbor
      continue unless distance is 5
      
      if Math.abs(rootPoint.x - rootNeighbor.x) is 2
        # Diagonal is more horizontal.
        x1 = x2 = (rootPoint.x + rootNeighbor.x) / 2
        y1 = rootPoint.y
        y2 = rootNeighbor.y
        
      else
        # Diagonal is more vertical.
        x1 = rootPoint.x
        x2 = rootNeighbor.x
        y1 = y2 = (rootPoint.y + rootNeighbor.y) / 2
        
      # If you can find both points, there will be a connection crossing this diagonal.
      continue unless _.find rootPoint.neighbors, (neighbor) => neighbor.x is x1 and neighbor.y is y1
      continue unless _.find rootPoint.neighbors, (neighbor) => neighbor.x is x2 and neighbor.y is y2
      
      diagonalPoints.push rootNeighbor

    for diagonalPoint in diagonalPoints
      rootPoint._disconnectNeighbor diagonalPoint
      diagonalPoint._disconnectNeighbor rootPoint
  
  for rootPoint in points
    # Eliminate triangles by removing the longer sides.
    loop
      eliminated = false
      
      for neighborA in rootPoint.neighbors
        distanceRA = rootPoint._distanceSquaredTo neighborA
  
        for neighborB in rootPoint.neighbors when neighborB isnt neighborA
          # See if these two points are connected, either directly or over another point (as is the case with doubles).
          unless neighborB in neighborA.neighbors or neighborB in neighborA.allNeighbors
            if rootPoint.radius is 1
              continue unless _.find neighborA.neighbors, (neighbor) =>
                return if neighbor is rootPoint
                return unless neighbor in neighborB.neighbors
                
                # Make sure the neighbor is on a straight line between two other points.
                return true if neighbor.x is (neighborA.x + neighborB.x) / 2 and neighbor.y is (neighborA.y + neighborB.y) / 2
                return true if neighborA.x is (rootPoint.x + neighbor.x) / 2 and neighborA.y is (rootPoint.y + neighbor.y) / 2
                return true if neighborB.x is (rootPoint.x + neighbor.x) / 2 and neighborB.y is (rootPoint.y + neighbor.y) / 2
                
                false
              
            else
              continue
          
          distanceRB = rootPoint._distanceSquaredTo neighborB
          distanceAB = neighborA._distanceSquaredTo neighborB
          
          if distanceAB > distanceRA and distanceAB > distanceRB
            eliminatingPoint1 = neighborA
            eliminatingPoint2 = neighborB
            outsidePoint = rootPoint
            
          else if distanceRA > distanceRB and distanceRA > distanceAB
            eliminatingPoint1 = rootPoint
            eliminatingPoint2 = neighborA
            outsidePoint = neighborB
            
          else if distanceRB > distanceRA and distanceRB > distanceAB
            eliminatingPoint1 = rootPoint
            eliminatingPoint2 = neighborB
            outsidePoint = neighborA
            
          else
            continue
            
          # Make sure the eliminating points are directly connected.
          continue unless eliminatingPoint1 in eliminatingPoint2.neighbors
          
          # Do not remove outline edges if that would break the outline (the outside point is not on the outline).
          sharedOutlineCore = @getSharedOutlineCore eliminatingPoint1, eliminatingPoint2
          outsidePixel = outsidePoint.getOutlinePixel()
          continue if sharedOutlineCore and (not outsidePixel or sharedOutlineCore not in outsidePixel.outlineCores)
          
          eliminatingPoint1._disconnectNeighbor eliminatingPoint2
          eliminatingPoint2._disconnectNeighbor eliminatingPoint1
          
          eliminated = true
          break
          
        break if eliminated
        
      break unless eliminated
      
  # Store all neighbors for certain analyses that require full connectivity.
  point.saveAllNeighbors() for point in points[0].layer.points
  
  # Eliminate non-outline connections between junctions (3 or more neighbors), since it's hard to determine meaningful
  # connectivity in that case. We need to first collect all connections and not remove them as we go along since that
  # would change their number of neighbors.
  eliminatedConnections = []
  
  for rootPoint in points when rootPoint.neighbors.length >= 3
    for neighbor in rootPoint.neighbors when neighbor.allNeighbors.length >= 3 and not (rootPoint.getOutlinePixel() and neighbor.getOutlinePixel())
      eliminatedConnections.push [rootPoint, neighbor]
  
  # Eliminate core extensions (short lines sticking out of cores, which should
  # be part of core outlines if we had better filtering when eliminating triangles).
  for rootPoint in points
    for neighbor in rootPoint.neighbors when rootPoint.getOutlinePixel() and neighbor.neighbors.length is 1 or neighbor.getOutlinePixel() and rootPoint.neighbors.length is 1
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
