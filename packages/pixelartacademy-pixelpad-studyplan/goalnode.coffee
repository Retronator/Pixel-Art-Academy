AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.GoalNode
  constructor: ->
    # Note: We add this first so it will appear in the object summary while debugging.
    @goalId = null
    
    @entryPoint = null
    @exitPoint = null
    @sidewaysPoints = []
    
    @taskPoints = []
    @taskPointsByTaskId = {}
    
    @taskPathways = []
    
    @forwardGoalNodes = []
    @sidewaysGoalNodes = []
    @parent = null
    
    @localPosition = new THREE.Vector2
    @globalPosition = new THREE.Vector2
    
    @width = 0
    @height = 0
    
  initialize: (@goalId) ->
    unless @goalClass = PAA.Learning.Goal.getClassForId @goalId
      console.warn "Unrecognized goal present in study plan.", @goalId
      return
    
    @goal = new @goalClass
    
    @entryPoint = new StudyPlan.ConnectionPoint
    @exitPoint = new StudyPlan.ConnectionPoint
    
    tasks = @goal.tasks()
    
    # Create task points.
    for task in tasks
      taskPoint = new StudyPlan.TaskPoint
      taskPoint.initializeTask task
      
      @taskPoints.push taskPoint
      @taskPointsByTaskId[task.id()] = taskPoint
    
    # Create links between task points.
    for task in tasks
      taskPoint = @taskPointsByTaskId[task.id()]
      
      predecessors = task.predecessors()
      
      if predecessors.length
        for predecessor in predecessors
          predecessorTaskPoint = @taskPointsByTaskId[predecessor.id()]
          taskPoint.predecessors.push predecessorTaskPoint
    
    # Create end task point.
    @endTaskPoint = new StudyPlan.TaskPoint
    @endTaskPoint.initializeEndTask()
    @endTaskPoint.groupNumber = @goal.finalGroupNumber()
    @taskPoints.push @endTaskPoint
    
    for task in @goal.finalTasks()
      taskPoint = @taskPointsByTaskId[task.id()]
      @endTaskPoint.predecessors.push taskPoint
      
    # Calculate levels.
    calculateLevel = (taskPoint) =>
      # See if we've already calculated it.
      return taskPoint.level if taskPoint.level?

      # Set and return level 0 when there are no predecessors.
      return taskPoint.level = 0 unless taskPoint.predecessors.length

      # If not, the level is one deeper than the highest predecessor.
      highestLevel = _.maxBy(taskPoint.predecessors, calculateLevel).level

      # Set and return the calculated level.
      taskPoint.level = highestLevel + 1

    loop
      addedNewTaskPoints = false
      
      # (Re)calculate all levels.
      taskPoint.level = taskPoint.task?.level() for taskPoint in @taskPoints
      calculateLevel taskPoint for taskPoint in @taskPoints

      # Put the end goal as the last level.
      @endTaskPoint.level = 0
      currentMaxLevel = _.max _.map @taskPoints, 'level'
      @endTaskPoint.level = currentMaxLevel + 1

      # Create dummy goal tasks in missing levels.
      for taskPoint in @taskPoints
        # Go over the predecessors, but clone them since we'll be mutating the array.
        for predecessor in _.clone taskPoint.predecessors when predecessor.level < taskPoint.level - 1
          # Find which nodes in the same group will need to be rewired.
          successors = _.filter @taskPoints, (taskPoint) =>
            taskPoint.groupNumber is predecessor.groupNumber and predecessor in taskPoint.predecessors

          # The task point itself also needs to be rewired.
          successors.push taskPoint

          lastTaskPoint = predecessor
          for missingLevel in [predecessor.level + 1...taskPoint.level]
            # Create the dummy goal in the same group as the predecessor and link it to the previous missing level.
            dummyTaskPoint = new StudyPlan.TaskPoint
            dummyTaskPoint.initializeDummyTask()
            dummyTaskPoint.level = missingLevel
            dummyTaskPoint.groupNumber = predecessor.groupNumber
            dummyTaskPoint.predecessors.push lastTaskPoint
            @taskPoints.push dummyTaskPoint
            
            addedNewTaskPoints = true
            lastTaskPoint = dummyTaskPoint

          # Rewire all successors to the missing level.
          for successor in successors
            _.pull successor.predecessors, predecessor
            successor.predecessors.push lastTaskPoint

      # Continue relaxing the graph until we didn't introduce any new nodes.
      break unless addedNewTaskPoints
      
    # Create pathways between task points.
    for taskPoint in @taskPoints
      if taskPoint.predecessors.length
        for predecessor in taskPoint.predecessors
          pathway = new StudyPlan.Pathway predecessor.exitPoint, taskPoint.entryPoint
          @taskPathways.push pathway
      
      else
        pathway = new StudyPlan.Pathway @entryPoint, taskPoint.entryPoint
        @taskPathways.push pathway
    
    pathway = new StudyPlan.Pathway @endTaskPoint.exitPoint, @exitPoint
    @taskPathways.push pathway
    
    # Prepare for distributing the tasks on the tilemap.

    @minGroupNumber = _.min _.map @taskPoints, 'groupNumber'
    @maxGroupNumber = _.max _.map @taskPoints, 'groupNumber'
    @maxLevel = _.max _.map @taskPoints, 'level'
    @levelsCount = @maxLevel + 1
    @groupsCount = @maxGroupNumber - @minGroupNumber + 1
  
    # Distribute levels.
    entryTileX = 1

    @levels = []
    
    for levelIndex in [0..@maxLevel]
      # Determine how many tiles are needed for this level.
      width = 0
      entryRequired = false
      exitRequired = true
      maxGroupNumberRequiringExit = Number.NEGATIVE_INFINITY
      
      for taskPoint in @taskPoints when taskPoint.level is levelIndex
        spaceBefore = 0
        spaceAfter = 0
        
        if taskPoint.task
          # Required interests must have space for a gate and an entry access road to get to it.
          if taskPoint.task.requiredInterests().length
            spaceBefore = 1
            entryRequired = true
            
          # Tasks that are placed after access roads should have some space
          # before to make it clear we can't get to them from the access road.
          if @levels[levelIndex - 1]?.exitRequired and taskPoint.groupNumber <= @levels[levelIndex - 1].maxGroupNumberRequiringExit
            spaceBefore = 1
          
          # Provided interests must have space for an access road.
          if taskPoint.task.interests().length
            spaceAfter = 1
            exitRequired = true
            maxGroupNumberRequiringExit = Math.max maxGroupNumberRequiringExit, taskPoint.groupNumber
            
          # Tasks where the road curves up should have space to make the left turn clearer.
          if _.find @taskPoints, (otherTaskPoint) => taskPoint in otherTaskPoint.predecessors and otherTaskPoint.groupNumber < taskPoint.groupNumber
            spaceAfter = 1
        
        taskPoint.setPositionX entryTileX + 1 + spaceBefore
        
        taskWidth = 1 + spaceBefore + spaceAfter
        width = Math.max width, taskWidth
        
      exitTileX = entryTileX + width + 1
      
      level = {entryTileX, exitTileX, maxGroupNumberRequiringExit}
      
      if entryRequired and levelIndex
        level.sideEntryPoint = new StudyPlan.ConnectionPoint
        level.sideEntryPoint.localPosition.x = entryTileX
        @sidewaysPoints.push level.sideEntryPoint
      
      if exitRequired and levelIndex < @maxLevel - 1 or not @goalClass.doesCompletingAnyFinalTaskCompleteTheGoal()
        level.sideExitPoint = new StudyPlan.ConnectionPoint
        level.sideExitPoint.localPosition.x = exitTileX
        @sidewaysPoints.push level.sideExitPoint
        
      @levels.push level
      
      entryTileX = exitTileX
      
    @exitPoint.localPosition.x = @endTaskPoint.exitPoint.localPosition.x + 1
    @exitPoint.localPosition.y = @endTaskPoint.exitPoint.localPosition.y
    
    # Distribute groups.
    @groupNumbers = {}
    lastGroupY = 0
    
    for groupNumber in [@minGroupNumber..@maxGroupNumber]
      groupNumberInfo =
        levelFilled: []
        
      @groupNumbers[groupNumber] = groupNumberInfo
      
      ySpacing = 2
      
      for goalTask in @taskPoints when goalTask.groupNumber is groupNumber and (goalTask.task or goalTask.endTask)
        # See if we need extra spacing from the level above.
        ySpacing = 4 if @groupNumbers[groupNumber - 1]?.levelFilled[goalTask.level]
        
        # Fill this spot.
        groupNumberInfo.levelFilled[goalTask.level] = true
        
        # Add roads in the same group as filled.
        for predecessor in goalTask.predecessors when predecessor.groupNumber is groupNumber
          for level in [predecessor.level...goalTask.level]
            groupNumberInfo.levelFilled[level] = true
            
            # Add extra space above the road.
            ySpacing = Math.max ySpacing, 3 if @groupNumbers[groupNumber - 1]?.levelFilled[level]
            
      groupNumberInfo.y = lastGroupY + ySpacing
      lastGroupY = groupNumberInfo.y
    
    # Shift Ys so group 0 is on 0.
    shiftY = -@groupNumbers[0].y
    
    for groupNumber, groupNumberInfo of @groupNumbers
      groupNumberInfo.y += shiftY

    # Create the tile map.
    @tileMap = new StudyPlan.TileMap
    
    accessRoadStartY = @groupNumbers[@minGroupNumber].y - 6
    connectionPoint.localPosition.y = accessRoadStartY for connectionPoint in @sidewaysPoints
    
    # Place tasks.
    for taskPoint in @taskPoints
      taskPoint.setPositionY @groupNumbers[taskPoint.groupNumber].y - 1
      
      # If it's not a dummy task, also place a building.
      if taskPoint.task
        @tileMap.placeTile taskPoint.localPosition.x, taskPoint.localPosition.y, StudyPlan.TileMap.Tile.Types.Building
        
        if taskPoint.task.requiredInterests().length
          @tileMap.placeTile taskPoint.localPosition.x - 1, taskPoint.localPosition.y + 2, StudyPlan.TileMap.Tile.Types.Gate
      
      if taskPoint.endTask
        @tileMap.placeTile taskPoint.localPosition.x, taskPoint.localPosition.y, StudyPlan.TileMap.Tile.Types.Flag
        
      # Add ground.
      for x in [taskPoint.localPosition.x - 1..taskPoint.localPosition.x + 1]
        for y in [taskPoint.localPosition.y - 2..taskPoint.localPosition.y + 2]
          @tileMap.placeTile x, y, StudyPlan.TileMap.Tile.Types.Ground
    
    # Add waypoints to pathways that change group numbers.
    for taskPoint in @taskPoints
      for predecessor in taskPoint.predecessors when taskPoint.groupNumber isnt predecessor.groupNumber
        startLevel = @levels[predecessor.level]
        endLevel = @levels[taskPoint.level]
        pathway = _.find taskPoint.entryPoint.incomingPathways, (pathway) => pathway.startPoint is predecessor.exitPoint
        pathway.localWaypointPositions.push new THREE.Vector2 startLevel.exitTileX, pathway.startPoint.localPosition.y
        pathway.localWaypointPositions.push new THREE.Vector2 endLevel.entryTileX, pathway.endPoint.localPosition.y
    
    # Place roads
    for taskPoint in @taskPoints
      @tileMap.placeRoad taskPoint.entryPoint.outgoingPathways[0]
      @tileMap.placeRoad pathway for pathway in taskPoint.entryPoint.incomingPathways
    
    @tileMap.placeRoad @endTaskPoint.exitPoint.outgoingPathways[0]
    
    # Create sideways points.
    for taskPoint in @taskPoints when taskPoint.task
      level = @levels[taskPoint.level]
      
      # Add entry roads if there are required interests and we're not the first task of the goal.
      if taskPoint.task.requiredInterests().length and level.sideEntryPoint
        pathway = new StudyPlan.Pathway level.sideEntryPoint, taskPoint.entryPoint
        pathway.localWaypointPositions.push new THREE.Vector2 level.entryTileX, pathway.endPoint.localPosition.y
        @taskPathways.push pathway
        @tileMap.placeRoad pathway, true
        
      # Add exit roads if there are interests and it can't lead directly to the exit of the goal.
      if taskPoint.task.interests().length and level.sideExitPoint
        pathway = new StudyPlan.Pathway taskPoint.exitPoint, level.sideExitPoint
        pathway.localWaypointPositions.push new THREE.Vector2 level.exitTileX, pathway.startPoint.localPosition.y
        @taskPathways.push pathway
        @tileMap.placeRoad pathway, true
        
    @tileMap.finishConstruction()
  
  calculateLocalPositions: ->
    # The base size is our tile map size.
    minX = @tileMap.minX
    minY = @tileMap.minY
    maxX = @tileMap.maxX
    maxY = @tileMap.maxY
    
    # Below the tile map is the goal title.
    maxY += StudyPlan.Blueprint.Goal.titleTileHeight

    # Place forward goals to the right of this goal.
    topY = null
    leftX = @exitPoint.localPosition.x + 4
    
    for goalNode in @forwardGoalNodes
      goalNode.calculateLocalPositions()
      
      rightX = leftX + goalNode.width - 1
      maxX = Math.max maxX, rightX
      
      topY ?= goalNode.tileMap.minY
      minY = Math.min minY, topY
      bottomY = topY + goalNode.height - 1
      maxY = Math.max maxY, bottomY

      goalNode.localPosition.set leftX - goalNode.tileMap.minX, topY - goalNode.tileMap.minY
      topY = bottomY + 1 + StudyPlan.Blueprint.Goal.verticalPadding
    
    # Place sideways goals above this goal.
    bottomY = Math.min(@tileMap.minY, @forwardGoalNodes[0]?.tileMap.minY or 0) - 1 - StudyPlan.Blueprint.Goal.verticalPadding
    
    for goalNode in @sidewaysGoalNodes
      goalNode.calculateLocalPositions()
      
      topY = bottomY - goalNode.height + 1
      minY = Math.min minY, topY
      
      maxX = Math.max maxX, goalNode.tileMap.maxX
      
      goalNode.localPosition.set -goalNode.tileMap.minX, topY - goalNode.tileMap.minY
      bottomY = topY - 1 - StudyPlan.Blueprint.Goal.verticalPadding
    
    @width = maxX - minX + 1
    @height = maxY - minY + 1
  
  calculateGlobalPositions: ->
    @globalPosition.set @parent.globalPosition.x + @localPosition.x, @parent.globalPosition.y + @localPosition.y if @parent
    
    goalNode.calculateGlobalPositions() for goalNode in @sidewaysGoalNodes
    goalNode.calculateGlobalPositions() for goalNode in @forwardGoalNodes
    
  cloneTemplate: (goalHierarchy) ->
    goalNode = new @constructor
    goalNode.goalHierarchy = goalHierarchy
    goalNode.goalId = @goalId
    goalNode.goalClass = @goalClass
    goalNode.goal = @goal
    
    connectionPointCloneMappings = []
    
    getConnectionPointClone = (connectionPoint) ->
      connectionPointCloneMapping = _.find connectionPointCloneMappings, (mapping) -> mapping.from is connectionPoint
      return connectionPointCloneMapping.to if connectionPointCloneMapping
      
      clonedConnectionPoint = connectionPoint.clone()
      connectionPointCloneMappings.push from: connectionPoint, to: clonedConnectionPoint
      clonedConnectionPoint
      
    goalNode.entryPoint = getConnectionPointClone @entryPoint
    goalNode.exitPoint = getConnectionPointClone @exitPoint
    
    for taskPoint in @taskPoints
      goalNode.taskPoints.push getConnectionPointClone taskPoint
    
    for taskPoint in @taskPoints
      clonedTaskPoint = getConnectionPointClone taskPoint
      
      for predecessor in taskPoint.predecessors
        clonedTaskPoint.predecessors.push getConnectionPointClone predecessor
      
    for pathway in @taskPathways
      pathway.clone getConnectionPointClone(pathway.startPoint), getConnectionPointClone(pathway.endPoint)
    
    goalNode.tileMap = @tileMap
    
    goalNode
    
  destroy: ->
    @goal.destroy()
