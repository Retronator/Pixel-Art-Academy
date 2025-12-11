AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.GoalHierarchy
  @goalPadding =
    left: 2
    top: 1
    right: 2
  
  constructor: (@blueprint, goalsData) ->
    @goalNodesById = {}
    
    goalsDataById = {}
    goalsDataList = []
    
    for goalId, goalData of goalsData
      unless PAA.Learning.Goal.getClassForId goalId
        console.warn "Unrecognized goal present in the hierarchy.", goalId
        continue
        
      @goalNodesById[goalId] = @blueprint.studyPlan.createGoalNode goalId, @

      goalData = _.extend {}, goalData, id: goalId
      goalsDataList.push goalData
      goalsDataById[goalId] = goalData
    
    # Root is the goal that no-one is connected to.
    rootGoalData = _.find goalsDataList, (goalData) =>
      incomingConnection = _.find goalsDataList, (otherGoalData) =>
        _.find otherGoalData.connections, (connection) => connection.goalId is goalData.id
      
      not incomingConnection
    
    # Recursively connect goal nodes.
    connect = (goalData) =>
      return unless goalData.connections
      goalNode = @goalNodesById[goalData.id]
      
      for connection in goalData.connections
        otherGoalData = goalsDataById[connection.goalId]
        otherGoalNode = @goalNodesById[otherGoalData.id]
        continue if otherGoalNode.parent
        
        otherGoalNode.parent = goalNode
        
        goalClass = PAA.Learning.Goal.getClassForId goalData.id
        
        if goalClass.isInterestProvidedFromIndividuallyCompletedFinalTask connection.interest
          connectingGoalNodes = goalNode.forwardGoalNodes
          
        else
          connectingGoalNodes = goalNode.sidewaysGoalNodes
        
        connectingGoalNodes.push otherGoalNode
        
        connect otherGoalData
    
    connect rootGoalData
    
    @rootGoalNode = @goalNodesById[rootGoalData.id]
    console.log "hierarchy", @rootGoalNode
    
    @roadTileMap = new ReactiveField null

    @_recalculateAutorun = Tracker.autorun (computation) =>
      console.log "recalc positions"
      @rootGoalNode.calculateLocalPositions()
      @rootGoalNode.calculateGlobalPositions()
      
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
        
      debugPathways = []
      
      debugPathway = (pathway) =>
        debugPathways.push pathway
        
      connectConnectionPoints = (connectionPoints) =>
        for connectionPointB, connectionPointAIndex in connectionPoints[1..]
          connectionPointA = connectionPoints[connectionPointAIndex]
          debugPathway new StudyPlan.Pathway connectionPointA, connectionPointB
          debugPathway new StudyPlan.Pathway connectionPointB, connectionPointA
      
      # Recursively create potential global road network.
      createGoalConnectionPoints = (goalNode) =>
        sidewaysGoalsConnectionPoints = (createGoalConnectionPoints sidewaysGoalNode for sidewaysGoalNode in goalNode.sidewaysGoalNodes)
        forwardGoalsConnectionPoints = (createGoalConnectionPoints forwardGoalNode for forwardGoalNode in goalNode.forwardGoalNodes)
        
        goalGlobalPosition = goalNode.globalPosition()
        entryX = goalNode.entryPoint.globalPosition.x - @constructor.goalPadding.left
        exitX = goalNode.exitPoint.globalPosition.x + @constructor.goalPadding.right
        topRoadY = goalGlobalPosition.y + goalNode.topRoadY
        bottomRoadY = goalGlobalPosition.y + goalNode.bottomRoadY
        
        entryConnection = new StudyPlan.ConnectionPoint
        entryConnection.globalPosition.set entryX, goalNode.entryPoint.globalPosition.y
        debugPathway new StudyPlan.Pathway entryConnection, goalNode.entryPoint

        exitConnection = new StudyPlan.ConnectionPoint
        exitConnection.globalPosition.set exitX, goalNode.exitPoint.globalPosition.y
        debugPathway new StudyPlan.Pathway goalNode.exitPoint, exitConnection
        
        sidewaysConnections = for sidewaysPoint in goalNode.sidewaysPoints
          sidewaysConnection = new StudyPlan.ConnectionPoint
          sidewaysConnection.globalPosition.set sidewaysPoint.globalPosition.x, topRoadY
          debugPathway new StudyPlan.Pathway sidewaysPoint, sidewaysConnection
          debugPathway new StudyPlan.Pathway sidewaysConnection, sidewaysPoint
          sidewaysConnection
        
        goalConnectionPoints =
          left: [entryConnection]
          up: []
          down: []
          accessHorizontal: []
          
        # Create access junction between the access horizontal and the vertical.
        accessJunction = new StudyPlan.ConnectionPoint
        accessJunction.globalPosition.set exitX, topRoadY
        
        # Create access horizontal if there are any sideways connections.
        if sidewaysConnections.length
          # Create the access horizontal.
          accessHorizontalEntryConnection = new StudyPlan.ConnectionPoint
          accessHorizontalEntryConnection.globalPosition.set entryX, topRoadY
          goalConnectionPoints.left.push accessHorizontalEntryConnection
          
          accessHorizontalConnections = [accessHorizontalEntryConnection, accessJunction, sidewaysConnections...]
          accessHorizontalConnections.push forwardGoalsConnectionPoints[0].accessHorizontal... if forwardGoalsConnectionPoints.length
          
          mergeHorizontalConnectionPoints accessHorizontalConnections
          connectConnectionPoints accessHorizontalConnections
          
          goalConnectionPoints.accessHorizontal.push accessHorizontalConnections...
        
        # Create main vertical that connects the access junction and bottom of the goal.
        bottomExit = new StudyPlan.ConnectionPoint
        bottomExit.globalPosition.set exitX, bottomRoadY
        mainVertical = [accessJunction, exitConnection, bottomExit]

        # Handle forward goals.
        
        if forwardGoalsConnectionPoints.length
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
                
                forwardHorizontalEntryConnection = new StudyPlan.ConnectionPoint
                forwardHorizontalEntryConnection.globalPosition.set entryConnection.globalPosition.x, forwardHorizontalY
                forwardHorizontalConnections.push forwardHorizontalEntryConnection
                mainVertical.left.push forwardHorizontalEntryConnection
                
                forwardHorizontalExitConnection = new StudyPlan.ConnectionPoint
                forwardHorizontalExitConnection.globalPosition.set exitConnection.globalPosition.x, forwardHorizontalY
                forwardHorizontalConnections.push forwardHorizontalExitConnection
                goalConnectionPoints.right.push forwardHorizontalExitConnection
                
                mergeHorizontalConnectionPoints forwardHorizontalConnections
                connectConnectionPoints forwardHorizontalConnections
            
        # Finalize the main vertical.
        mergeVerticalConnectionPoints mainVertical
        connectConnectionPoints mainVertical
        
        goalConnectionPoints.down.push _.last mainVertical
        
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
            topOfFirstForwardGoal = firstForwardGoalNode.absolutePosition().y + firstForwardGoalNode.minY
            mainHorizontalY = Math.min mainHorizontalY, topOfFirstForwardGoal
          
          # Create main junction between the main horizontal and the vertical.
          mainJunction = new StudyPlan.ConnectionPoint
          mainJunction.globalPosition.set exitX, mainHorizontalY
          mainVertical.push mainJunction
          
          # Create the main horizontal.
          mainHorizontalEntryConnection = new StudyPlan.ConnectionPoint
          mainHorizontalEntryConnection.globalPosition.set entryX, mainHorizontalY
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
                
                sidewaysHorizontalEntryConnection = new StudyPlan.ConnectionPoint
                sidewaysHorizontalEntryConnection.globalPosition.set entryConnection.globalPosition.x, sidewaysHorizontalY
                sidewaysHorizontalConnections.push sidewaysHorizontalEntryConnection
                goalConnectionPoints.left.push sidewaysHorizontalEntryConnection
                
                sidewaysHorizontalExitConnection = new StudyPlan.ConnectionPoint
                sidewaysHorizontalExitConnection.globalPosition.set exitConnection.globalPosition.x, sidewaysHorizontalY
                sidewaysHorizontalConnections.push sidewaysHorizontalExitConnection
                
                mergeHorizontalConnectionPoints sidewaysHorizontalConnections
                connectConnectionPoints sidewaysHorizontalConnections
        
        # Create entry vertical that connects all left connection points.
        entryVertical = [goalConnectionPoints.left...]
        mergeVerticalConnectionPoints entryVertical
        connectConnectionPoints entryVertical
        
        goalConnectionPoints
      
      createGoalConnectionPoints @rootGoalNode
      
      for pathway in debugPathways
        roadTileMap.placeRoad pathway, useGlobalPositions: true, noBlueprint: true
      
      roadTileMap.finishConstruction noBlueprintEdges: true
      
      @roadTileMap roadTileMap
      
  destroy: ->
    @_recalculateAutorun.stop()
