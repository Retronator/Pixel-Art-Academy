AE = Artificial.Everywhere
AP = Artificial.Program
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.GoalHierarchy
  @goalPadding =
    left: 2
    top: 2
    right: 2
    bottom: 4
    
  @goalIslandSpacing = 10
  
  constructor: (@blueprint, goalsData) ->
    @goalNodesById = {}
    @taskPointsById = {}
    
    goalsDataById = {}
    goalsDataList = []
    
    for goalId, goalData of goalsData
      unless PAA.Learning.Goal.getClassForId goalId
        console.warn "Unrecognized goal present in the hierarchy.", goalId
        continue
        
      @goalNodesById[goalId] = @blueprint.studyPlan.createGoalNode goalId, @
      @taskPointsById[taskId] = taskPoint for taskId, taskPoint of @goalNodesById[goalId].taskPointsById

      goalData = _.extend {}, goalData, id: goalId
      goalsDataList.push goalData
      goalsDataById[goalId] = goalData
    
    # Roots are the goals that no-one is connected to.
    rootGoalsData = _.filter goalsDataList, (goalData) =>
      incomingConnection = _.find goalsDataList, (otherGoalData) =>
        _.find otherGoalData.connections, (connection) => connection.goalId is goalData.id
      
      not incomingConnection
    
    # Recursively connect goal nodes.
    connect = (goalData) =>
      return unless goalData.connections
      goalNode = @goalNodesById[goalData.id]
      
      for connection in goalData.connections
        continue unless otherGoalData = goalsDataById[connection.goalId]
        otherGoalNode = @goalNodesById[otherGoalData.id]
        continue if otherGoalNode.parent
        
        otherGoalNode.parent = goalNode
        
        goalClass = PAA.Learning.Goal.getClassForId goalData.id
        
        if connection.direction
          switch connection.direction
            when StudyPlan.GoalConnectionDirections.Forward then connectingGoalNodes = goalNode.forwardGoalNodes
            when StudyPlan.GoalConnectionDirections.Sideways then connectingGoalNodes = goalNode.sidewaysGoalNodes
        
        else
          if goalClass.isInterestProvidedFromIndividuallyCompletedFinalTask connection.interest
            connectingGoalNodes = goalNode.forwardGoalNodes
            
          else
            connectingGoalNodes = goalNode.sidewaysGoalNodes
        
        connectingGoalNodes.push otherGoalNode
        
        connect otherGoalData
    
    connect rootGoalData for rootGoalData in rootGoalsData
    
    @rootGoalNodes = (@goalNodesById[rootGoalData.id] for rootGoalData in rootGoalsData)
    
    # Create global pathways.
    
    @roadTileMap = new ReactiveField null
    
    @_globalPathways = []
    
    addGlobalPathway = (pathway) =>
      @_globalPathways.push pathway

    @_recalculateAutorun = Tracker.autorun (computation) =>
      goalIslandXPosition = 0
      
      for rootGoalNode in @rootGoalNodes
        rootGoalNode.calculateLocalPositions()
        
        rootGoalNode.globalPosition new THREE.Vector2 goalIslandXPosition, 0
        rootGoalNode.calculateGlobalPositions()
        
        goalIslandXPosition += rootGoalNode.width + @constructor.goalIslandSpacing
      
      roadTileMap = new StudyPlan.TileMap
      
      mergeHorizontalConnectionPoints = (connectionPoints, topAligned = true) =>
        connectionPoints.sort (a, b) => a.globalPosition.x - b.globalPosition.x
        yS = (point.globalPosition.y for point in connectionPoints)
        y = if topAligned then _.min yS else _.max yS
        connectionPoint.globalPosition.y = y for connectionPoint in connectionPoints
      
      mergeVerticalConnectionPoints = (connectionPoints, leftAligned = true) =>
        connectionPoints.sort (a, b) => a.globalPosition.y - b.globalPosition.y
        xS = (point.globalPosition.x for point in connectionPoints)
        x = if leftAligned then _.min xS else _.max xS
        connectionPoint.globalPosition.x = x for connectionPoint in connectionPoints
        
      # Remove all existing global pathways for a new rewiring.
      pathway.remove() for pathway in @_globalPathways
      @_globalPathways = []
      
      connectConnectionPoints = (connectionPoints) =>
        for connectionPointB, connectionPointAIndex in connectionPoints[1..]
          connectionPointA = connectionPoints[connectionPointAIndex]
          addGlobalPathway new StudyPlan.Pathway connectionPointA, connectionPointB
          addGlobalPathway new StudyPlan.Pathway connectionPointB, connectionPointA
      
      # Recursively create potential global road network.
      createGoalConnectionPoints = (goalNode) =>
        sidewaysGoalsConnectionPoints = (createGoalConnectionPoints sidewaysGoalNode for sidewaysGoalNode in goalNode.sidewaysGoalNodes)
        forwardGoalsConnectionPoints = (createGoalConnectionPoints forwardGoalNode for forwardGoalNode in goalNode.forwardGoalNodes)
        
        goalGlobalPosition = goalNode.globalPosition()
        entryX = goalNode.entryPoint.globalPosition.x - @constructor.goalPadding.left
        exitX = goalNode.exitPoint.globalPosition.x + @constructor.goalPadding.right
        topRoadY = goalGlobalPosition.y + goalNode.topRoadY
        bottomRoadY = goalGlobalPosition.y + goalNode.bottomRoadY
        
        entryConnection = StudyPlan.ConnectionPoint.createGlobal entryX, goalNode.entryPoint.globalPosition.y
        addGlobalPathway new StudyPlan.Pathway entryConnection, goalNode.entryPoint

        exitConnection = StudyPlan.ConnectionPoint.createGlobal exitX, goalNode.exitPoint.globalPosition.y
        addGlobalPathway new StudyPlan.Pathway goalNode.exitPoint, exitConnection
        
        sidewaysConnections = for sidewaysPoint in goalNode.sidewaysPoints
          sidewaysConnection = StudyPlan.ConnectionPoint.createGlobal sidewaysPoint.globalPosition.x, topRoadY
          addGlobalPathway new StudyPlan.Pathway sidewaysPoint, sidewaysConnection
          addGlobalPathway new StudyPlan.Pathway sidewaysConnection, sidewaysPoint
          sidewaysConnection
        
        goalConnectionPoints =
          left: [entryConnection]
          up: []
          down: []
          accessHorizontal: []
          
        # Create access junction between the access horizontal and the vertical.
        accessJunction = StudyPlan.ConnectionPoint.createGlobal exitX, topRoadY
        
        # Create access horizontal if there are any sideways connections.
        if sidewaysConnections.length
          # Create the access horizontal.
          accessHorizontalEntryConnection = StudyPlan.ConnectionPoint.createGlobal entryX, topRoadY
          goalConnectionPoints.left.push accessHorizontalEntryConnection
          
          accessHorizontalConnections = [accessHorizontalEntryConnection, accessJunction, sidewaysConnections...]
          accessHorizontalConnections.push forwardGoalsConnectionPoints[0].accessHorizontal... if forwardGoalsConnectionPoints.length
          
          mergeHorizontalConnectionPoints accessHorizontalConnections
          connectConnectionPoints accessHorizontalConnections
          
          goalConnectionPoints.accessHorizontal.push accessHorizontalConnections...
        
        # Create main vertical that connects the access junction and bottom of the goal.
        bottomExit = StudyPlan.ConnectionPoint.createGlobal exitX, bottomRoadY
        mainVertical = [accessJunction, exitConnection, bottomExit]

        # Handle forward goals.
        if forwardGoalsConnectionPoints.length
          # All forward goals are left-aligned to the vertical.
          for forwardGoalConnectionPoints in forwardGoalsConnectionPoints
            mainVertical.push forwardGoalConnectionPoints.left...
            
          # The down connections of the last forward goal are the down connections of the combined goal.
          goalConnectionPoints.down.push _.last(forwardGoalsConnectionPoints).down...
          mergeHorizontalConnectionPoints goalConnectionPoints.down, false
          
          if forwardGoalsConnectionPoints.length > 1
            # Create intermediary horizontals.
            for forwardGoalBConnectionPoints, forwardGoalAIndex in forwardGoalsConnectionPoints[1..]
              forwardGoalAConnectionPoints = forwardGoalsConnectionPoints[forwardGoalAIndex]
              forwardHorizontalConnections = [forwardGoalAConnectionPoints.up..., forwardGoalBConnectionPoints.down...]
              
              if forwardHorizontalConnections.length
                forwardHorizontalY = forwardHorizontalConnections[0].globalPosition.y
                
                forwardHorizontalEntryConnection = StudyPlan.ConnectionPoint.createGlobal entryConnection.globalPosition.x, forwardHorizontalY
                forwardHorizontalConnections.push forwardHorizontalEntryConnection
                mainVertical.push forwardHorizontalEntryConnection
                
                forwardHorizontalExitConnection = StudyPlan.ConnectionPoint.createGlobal exitConnection.globalPosition.x, forwardHorizontalY
                forwardHorizontalConnections.push forwardHorizontalExitConnection
                goalConnectionPoints.right.push forwardHorizontalExitConnection
                
                mergeHorizontalConnectionPoints forwardHorizontalConnections
                connectConnectionPoints forwardHorizontalConnections
            
        # Handle sideways goals.
        if sidewaysGoalsConnectionPoints.length is 0
          # There are no sideways goals above, so the access horizontal is also the top of the goal.
          goalConnectionPoints.up.push accessHorizontalConnections... if accessHorizontalConnections
          
        else
          # All sideways goals are left-aligned to this goal.
          for sidewaysGoalConnectionPoints in sidewaysGoalsConnectionPoints
            goalConnectionPoints.left.push sidewaysGoalConnectionPoints.left...
          
          # The up connections of the last sideways goal are the up connections of the combined goal.
          goalConnectionPoints.up.push _.last(sidewaysGoalsConnectionPoints).up...
        
          # We need a main horizontal that connect the bottom of the first sideways goal and the top of the first forward goal.
          mainHorizontalY = topRoadY
          
          if firstForwardGoalNode = goalNode.forwardGoalNodes[0]
            topOfFirstForwardGoal = firstForwardGoalNode.globalPosition().y + firstForwardGoalNode.minY
            mainHorizontalY = Math.min mainHorizontalY, topOfFirstForwardGoal
          
          # Create main junction between the main horizontal and the vertical.
          mainJunction = StudyPlan.ConnectionPoint.createGlobal exitX, mainHorizontalY
          mainVertical.push mainJunction
          
          # Create the main horizontal.
          mainHorizontalEntryConnection = StudyPlan.ConnectionPoint.createGlobal entryX, mainHorizontalY
          goalConnectionPoints.left.push mainHorizontalEntryConnection
          
          # First align the horizontal above the first forward goal and the main junction.
          mainHorizontalConnections = [mainHorizontalEntryConnection, mainJunction]
          mainHorizontalConnections.push forwardGoalsConnectionPoints[0].up... if forwardGoalsConnectionPoints.length
          mergeHorizontalConnectionPoints mainHorizontalConnections
          
          # Now align the first sideways goal down to the horizontal.
          mainHorizontalConnections.push sidewaysGoalsConnectionPoints[0].down...
          mergeHorizontalConnectionPoints mainHorizontalConnections, false
          
          connectConnectionPoints mainHorizontalConnections
        
          if sidewaysGoalsConnectionPoints.length > 1
            # Create intermediary horizontals.
            for sidewaysGoalBConnectionPoints, sidewaysGoalAIndex in sidewaysGoalsConnectionPoints[1..]
              sidewaysGoalAConnectionPoints = sidewaysGoalsConnectionPoints[sidewaysGoalAIndex]
              sidewaysHorizontalConnections = [sidewaysGoalAConnectionPoints.up..., sidewaysGoalBConnectionPoints.down...]
              
              if sidewaysHorizontalConnections.length
                sidewaysHorizontalY = sidewaysHorizontalConnections[0].globalPosition.y
                
                sidewaysHorizontalEntryConnection = StudyPlan.ConnectionPoint.createGlobal entryConnection.globalPosition.x, sidewaysHorizontalY
                sidewaysHorizontalConnections.push sidewaysHorizontalEntryConnection
                goalConnectionPoints.left.push sidewaysHorizontalEntryConnection
                
                sidewaysHorizontalExitConnection = StudyPlan.ConnectionPoint.createGlobal exitConnection.globalPosition.x, sidewaysHorizontalY
                sidewaysHorizontalConnections.push sidewaysHorizontalExitConnection
                
                mergeHorizontalConnectionPoints sidewaysHorizontalConnections
                connectConnectionPoints sidewaysHorizontalConnections
        
        # Finalize the main vertical.
        mergeVerticalConnectionPoints mainVertical
        connectConnectionPoints mainVertical
        
        goalConnectionPoints.down.push _.last mainVertical
        
        # Create entry vertical that connects all left connection points.
        entryVertical = [goalConnectionPoints.left...]
        mergeVerticalConnectionPoints entryVertical
        connectConnectionPoints entryVertical
        
        goalConnectionPoints
      
      createGoalConnectionPoints rootGoalNode for rootGoalNode in @rootGoalNodes
      
      # Create pathways for all goal connections.
      paths = []
      
      for goalData in goalsDataList when goalData.connections
        for connection in goalData.connections
          startGoal = @goalNodesById[goalData.id]
          continue unless endGoal = @goalNodesById[connection.goalId]
          
          if connection.direction
            switch connection.direction
              when StudyPlan.GoalConnectionDirections.Forward then startPoint = startGoal.exitPoint
              when StudyPlan.GoalConnectionDirections.Sideways then startPoint = startGoal.sidewaysPoints[connection.sidewaysIndex or 0]
            
            endPoint = endGoal.entryPoint
          
          else
            startPoint = startGoal.getExitPointForInterest connection.interest
            endPoint = endGoal.getEntryPointForInterest connection.interest
          
          paths.push path if path = @pathfind startPoint, endPoint
          
      # Replace all global pathways with needed paths.
      pathway.remove() for pathway in @_globalPathways
      @_globalPathways = []
      
      for path in paths
        startPoint = path[0].startPoint
        globalWaypointPositions = []
        
        for pathway in path
          globalWaypointPositions.push pathway.globalWaypointPositions...
          globalWaypointPositions.push pathway.endPoint.globalPosition
          
        globalWaypointPositions.pop()
        endPoint = _.last(path).endPoint
        
        pathway = new StudyPlan.Pathway startPoint, endPoint
        pathway.globalWaypointPositions = globalWaypointPositions
        addGlobalPathway pathway

        roadTileMap.placeRoad pathway, useGlobalPositions: true
      
      # Propagate interests.
      rootGoalNode.entryPoint.propagateInterests() for rootGoalNode in @rootGoalNodes
      
      # Distribute possible goals.
      possibleGoals = @blueprint.studyPlan.goals().slice()
      
      for goalId, goalNode of @goalNodesById
        _.remove possibleGoals, (goal) => goal.id() is goalNode.goalId
        
        goalNode.possibleForwardGoalIDs = []
        goalNode.possibleSidewaysGoalIDs = []
        
      availableGoalIDs = (interests) =>
        goals = []
        
        for goal in possibleGoals
          for task in goal.initialTasks()
            requiredInterests = task.requiredInterests()
            if _.intersection(requiredInterests, interests).length is requiredInterests.length
              goals.push goal
        
        _.pull possibleGoals, goals...
        
        goal.id() for goal in goals
      
      distributePossibleGoals = (goalNode, interestsCollectionName) =>
        # Go across sideways expansion points first since those can be completed earliest.
        for sidewaysPoint, sidewaysPointIndex in goalNode.sidewaysPoints
          goalNode.possibleSidewaysGoalIDs[sidewaysPointIndex] ?= []
          goalNode.possibleSidewaysGoalIDs[sidewaysPointIndex].push (availableGoalIDs sidewaysPoint[interestsCollectionName])...
          
          for outgoingPathway in sidewaysPoint.outgoingPathways when outgoingPathway.endPoint is outgoingPathway.endPoint.goalNode?.entryPoint
            distributePossibleGoals outgoingPathway.endPoint.goalNode, interestsCollectionName
            
        # See if we can add any goals forward.
        goalNode.possibleForwardGoalIDs.push availableGoalIDs(goalNode.exitPoint[interestsCollectionName])...
        
        for outgoingPathway in goalNode.exitPoint.outgoingPathways
          distributePossibleGoals outgoingPathway.endPoint.goalNode, interestsCollectionName
        
      # Add short-term goals first.
      distributePossibleGoals rootGoalNode, 'propagatedAvailableInterests' for rootGoalNode in @rootGoalNodes

      # Add the rest of the goals.
      # TODO: Enable when mid-term goals are allowed to be added by the player.
      # distributePossibleGoals rootGoalNode, 'propagatedProvidedInterests' for rootGoalNode in @rootGoalNodes
      
      # Place expansion points.
      for goalId, goalNode of @goalNodesById
        # If there are forward goal nodes, we have to expand down, otherwise forward.
        if goalNode.possibleForwardGoalIDs.length
          if goalNode.forwardGoalNodes.length
            exitX = goalNode.exitPoint.globalPosition.x + @constructor.goalPadding.right
            testY = goalNode.exitPoint.globalPosition.y
            
            testY++ while roadTileMap.getTileType(exitX, testY) is StudyPlan.TileMap.Tile.Types.Road
            roadTileMap.placeTile exitX, testY, StudyPlan.TileMap.Tile.Types.Road
            
            roadTileMap.placeExpansionPoint exitX, testY + 2, StudyPlan.TileMap.Tile.ExpansionDirections.ForwardDown, goalNode.possibleForwardGoalIDs,
              goalId: goalId
              exit: true
          
          else
            expansionPosition = goalNode.exitPoint.globalPosition
            roadTileMap.placeExpansionPoint expansionPosition.x + 2, expansionPosition.y, StudyPlan.TileMap.Tile.ExpansionDirections.Forward, goalNode.possibleForwardGoalIDs,
              goalId: goalId
              exit: true
            
        # We can expand sideways where there are no outgoing pathways.
        sidewaysExpansionPossible = false
        
        for sidewaysPoint, index in goalNode.sidewaysPoints
          continue unless goalNode.possibleSidewaysGoalIDs[index]?.length
          sidewaysExpansionPossible = true
          continue if sidewaysPoint.outgoingPathways.length
          
          expansionPosition = sidewaysPoint.globalPosition
          
          # If there are sideways roads going past this expansion point, just connect the road.
          if roadTileMap.getTileType(expansionPosition.x, expansionPosition.y - 2) is StudyPlan.TileMap.Tile.Types.Road
            expansionRoadPoint = StudyPlan.ConnectionPoint.createGlobal expansionPosition.x, expansionPosition.y - 1
            pathway = new StudyPlan.Pathway sidewaysPoint, expansionRoadPoint
            addGlobalPathway pathway
            
            roadTileMap.placeRoad pathway, useGlobalPositions: true
          
          else
            roadTileMap.placeExpansionPoint expansionPosition.x, expansionPosition.y - 2, StudyPlan.TileMap.Tile.ExpansionDirections.Sideways, goalNode.possibleSidewaysGoalIDs[index],
              goalId: goalId
              sidewaysIndex: index
              
        # Add the sideways expansion point at the top of the entry vertical.
        if sidewaysExpansionPossible and goalNode.sidewaysGoalNodes.length
          entryX = goalNode.entryPoint.globalPosition.x - @constructor.goalPadding.left
          
          lastSidewaysGoalNode = _.last goalNode.sidewaysGoalNodes
          entryY = lastSidewaysGoalNode.globalPosition().y
          
          expansionRoadPoint = StudyPlan.ConnectionPoint.createGlobal entryX, entryY - 1
          pathway = new StudyPlan.Pathway lastSidewaysGoalNode.entryPoint, expansionRoadPoint
          pathway.globalWaypointPositions.push new THREE.Vector2 entryX, entryY
          addGlobalPathway pathway
          
          roadTileMap.placeRoad pathway, useGlobalPositions: true
          roadTileMap.placeExpansionPoint entryX, entryY - 3, StudyPlan.TileMap.Tile.ExpansionDirections.Sideways, goalNode.possibleSidewaysGoalIDs,
            goalId: goalId
            
        # We can connect backwards if the goal has required interests, but there is no predecessor set.
        if goalNode.goal.requiredInterests().length and not goalNode.parent
          expansionPosition = goalNode.entryPoint.globalPosition
          roadTileMap.placeExpansionPoint expansionPosition.x - 2, expansionPosition.y, StudyPlan.TileMap.Tile.ExpansionDirections.Backwards, [],
            goalId: goalId
            entry: true
        
      # Place initial expansion point if there are no goals at all.
      unless goalsDataList.length
        roadTileMap.placeExpansionPoint 0, 0, StudyPlan.TileMap.Tile.ExpansionDirections.Forward, availableGoalIDs []
      
      roadTileMap.finishConstruction()
      
      @roadTileMap roadTileMap
      
  destroy: ->
    @_recalculateAutorun.stop()
    
  pathfind: (startPoint, endPoint) ->
    AP.Search.BreadthFirstSearch.searchEdges
      root: startPoint
      isGoal: (point) => point is endPoint
      getEdgeStart: (pathway) => pathway.startPoint
      getEdgeEnd: (pathway) => pathway.endPoint
      getDescendentEdges: (point) => point.outgoingPathways
