AP = Artificial.Program

class AP.Search.BreadthFirstSearch
  @searchNodes: (options) ->
    # Explore descendants in first-in-first-out order.
    descendentNodes = []
    
    # Track visited nodes.
    visitedNodes = new Set
    
    # Track parent relationships.
    parentNodes = new Map
    
    # Start from the root.
    visitedNodes.add options.root
    descendentNodes.push options.root
    
    # Continue while queue is not empty
    while descendentNodes.length
      # Get the next node.
      node = descendentNodes.shift()
      
      # Check if we found the goal.
      if options.isGoal node
        # Create a path from the root to the goal.
        path = [node]

        while node isnt options.root
          node = parentNodes.get node
          path.unshift node
          
        return path
      
      # Explore all adjacent edges
      for descendentNode in options.getDescendentNodes node when not visitedNodes.has descendentNode
        # Mark as visited and set as parent.
        visitedNodes.add descendentNode
        parentNodes.set descendentNode, node
        descendentNodes.push descendentNode

    # The goal was not found.
    null

  @searchEdges: (options) ->
    # Explore descendants in first-in-first-out order.
    descendentNodes = []
    
    # Track visited nodes.
    visitedNodes = new Set
    
    # Track parent relationships.
    parentEdges = new Map
    
    # Start from the root.
    visitedNodes.add options.root
    descendentNodes.push options.root
    
    # Continue while queue is not empty
    while descendentNodes.length
      # Get the next node.
      node = descendentNodes.shift()
      
      # Check if we found the goal.
      if options.isGoal node
        # Create a path from the root to the goal.
        path = []

        while node isnt options.root
          edge = parentEdges.get node
          path.unshift edge
          node = options.getEdgeStart edge
          
        return path
      
      # Explore all adjacent edges
      for descendentEdge in options.getDescendentEdges node
        descendentEdgeEnd = options.getEdgeEnd descendentEdge
        continue if visitedNodes.has descendentEdgeEnd
        
        # Mark as visited and set as parent.
        visitedNodes.add descendentEdgeEnd
        parentEdges.set descendentEdgeEnd, descendentEdge
        descendentNodes.push descendentEdgeEnd

    # The goal was not found.
    null
