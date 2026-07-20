AP = Artificial.Program

class AP.Search.Dijkstra
  @searchEdges: (options) ->
    # Explore reachable nodes in order of increasing distance from the root.
    fringeNodes = []

    # Track nodes for which the shortest path has already been found.
    visitedNodes = new Set

    # Track shortest distances and parent relationships.
    nodeDistances = new Map
    parentEdges = new Map

    # Start from the root.
    nodeDistances.set options.root, 0
    fringeNodes.push options.root

    # Continue while there are still reachable nodes to visit.
    while fringeNodes.length
      # Remove the closest node from the fringe.
      _.sortBy fringeNodes, (node) => nodeDistances.get node
      node = fringeNodes.shift()
      visitedNodes.add node

      # Check if we found the goal.
      if options.isGoal node
        # Create a path from the root to the goal.
        path = []

        while node isnt options.root
          edge = parentEdges.get node
          path.unshift edge
          node = options.getEdgeStart edge

        return path

      # Explore all adjacent edges and update shortest paths to their end nodes.
      for descendentEdge in options.getDescendentEdges node
        descendentEdgeEnd = options.getEdgeEnd descendentEdge
        continue if visitedNodes.has descendentEdgeEnd

        edgeDistance = options.getEdgeDistance descendentEdge
        alternativeDistance = nodeDistances.get(node) + edgeDistance
        currentDistance = nodeDistances.get descendentEdgeEnd

        continue if currentDistance and currentDistance <= alternativeDistance

        # Store the better path.
        nodeDistances.set descendentEdgeEnd, alternativeDistance
        parentEdges.set descendentEdgeEnd, descendentEdge
        
        continue if currentDistance?
        
        # Add the newly discovered node to the fringe.
        fringeNodes.push descendentEdgeEnd

    # The goal was not found.
    null
