AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelPad.Apps.StudyPlan.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Goal'
  @register @id()
  
  @TileTypes =
    Blueprint: 'Blueprint'
    Road: 'Road'
    Sidewalk: 'Sidewalk'
    Ground: 'Ground'
    Building: 'Building'

  constructor: (goalOrOptions) ->
    super arguments...

    if goalOrOptions instanceof PAA.Learning.Goal
      @goal = goalOrOptions

    else
      {@goal, @state, @blueprint} = goalOrOptions

      @position = @state.field 'position',
        equalityFunction: EJSON.equals
        lazyUpdates: true
        
      @expanded = @state.field 'expanded',
        lazyUpdates: true
  
    @goalTasks = []
    @goalTasksByTaskId = {}

    # Create goal tasks so that we can attach extra info to them.
    for task in @goal.tasks()
      goalTask =
        task: task
        groupNumber: task.groupNumber()

      @goalTasks.push goalTask
      @goalTasksByTaskId[task.id()] = goalTask

    # Create links between goal tasks.
    for goalTask in @goalTasks
      goalTask.predecessors = for predecessor in goalTask.task.predecessors()
        @goalTasksByTaskId[predecessor.id()]

    @endGoalTask =
      groupNumber: @goal.finalGroupNumber()
      predecessors: @goalTasksByTaskId[task.id()] for task in @goal.finalTasks()
      endTask: true

    @goalTasks.push @endGoalTask

    # Calculate levels.
    calculateLevel = (goalTask) =>
      # See if we've already calculated it.
      return goalTask.level if goalTask.level?

      # Set and return level 0 when there are no predecessors.
      return goalTask.level = 0 unless goalTask.predecessors.length

      # If not, the level is one deeper than the highest predecessor.
      highestLevel = _.maxBy(goalTask.predecessors, calculateLevel).level

      # Set and return the calculated level.
      goalTask.level = highestLevel + 1

    loop
      addedNewTasks = false

      # (Re)calculate all levels.
      goalTask.level = goalTask.task?.level() for goalTask in @goalTasks
      calculateLevel goalTask for goalTask in @goalTasks

      # Put the end goal as the last level.
      @endGoalTask.level = 0
      currentMaxLevel = _.max _.map @goalTasks, 'level'
      @endGoalTask.level = currentMaxLevel + 1

      # Create dummy goal tasks in missing levels.
      for goalTask in @goalTasks
        # Go over the predecessors, but clone them since we'll be mutating the array.
        for predecessor in _.clone goalTask.predecessors when predecessor.level < goalTask.level - 1
          # Find which nodes in the same group will need to be rewired.
          successors = _.filter @goalTasks, (goalTask) =>
            goalTask.groupNumber is predecessor.groupNumber and predecessor in goalTask.predecessors

          # The goal task itself also needs to be rewired.
          successors.push goalTask

          lastGoalTask = predecessor
          for missingLevel in [predecessor.level + 1...goalTask.level]
            # Create the dummy goal in the same group as the predecessor and link it to the previous missing level.
            lastGoalTask =
              level: missingLevel
              groupNumber: predecessor.groupNumber
              predecessors: [lastGoalTask]

            @goalTasks.push lastGoalTask
            addedNewTasks = true

          # Rewire all successors to the missing level.
          for successor in successors
            _.pull successor.predecessors, predecessor
            successor.predecessors.push lastGoalTask

      # Continue relaxing the graph until we didn't introduce any new nodes.
      break unless addedNewTasks

    @minGroupNumber = _.min _.map @goalTasks, 'groupNumber'
    @maxGroupNumber = _.max _.map @goalTasks, 'groupNumber'
    @maxLevel = _.max _.map @goalTasks, 'level'
    @levelsCount = @maxLevel + 1
    @groupsCount = @maxGroupNumber - @minGroupNumber + 1

    # Distribute levels.
    entryTileX = 1

    @levels = []
    
    for level in [0..@maxLevel]
      # Determine how many tiles are needed for this level.
      width = 0
      entryRequired = false
      exitRequired = true
      maxGroupNumberRequiringExit = Number.NEGATIVE_INFINITY
      
      for goalTask in @goalTasks when goalTask.level is level
        spaceBefore = 0
        spaceAfter = 0
        
        if goalTask.task
          # Required interests must have space for a gate and an entry access road to get to it.
          if goalTask.task.requiredInterests().length
            spaceBefore = 1
            entryRequired = true
            
          # Tasks that are placed after access roads should have some space
          # before to make it clear we can't get to them from the access road.
          if @levels[level - 1]?.exitRequired and goalTask.groupNumber <= @levels[level - 1].maxGroupNumberRequiringExit
            spaceBefore = 1
          
          # Provided interests must have space for an access road.
          if goalTask.task.interests().length
            spaceAfter = 1
            exitRequired = true
            maxGroupNumberRequiringExit = Math.max maxGroupNumberRequiringExit, goalTask.groupNumber
            
          # Tasks where the road curves up should have space to make the left turn clearer.
          if _.find @goalTasks, (otherGoalTask) => goalTask in otherGoalTask.predecessors and otherGoalTask.groupNumber < goalTask.groupNumber
            spaceAfter = 1
        
        goalTask.tileX = entryTileX + 1 + spaceBefore
        
        taskWidth = 1 + spaceBefore + spaceAfter
        width = Math.max width, taskWidth
        
      exitTileX = entryTileX + width + 1
      
      @levels.push {entryTileX, exitTileX, entryRequired, exitRequired, maxGroupNumberRequiringExit}
      
      entryTileX = exitTileX
      
    # Distribute groups.
    @groupNumbers = {}
    lastGroupY = 0
    
    for groupNumber in [@minGroupNumber..@maxGroupNumber]
      groupNumberInfo =
        levelFilled: []
        
      @groupNumbers[groupNumber] = groupNumberInfo
      
      ySpacing = 2
      
      for goalTask in @goalTasks when goalTask.groupNumber is groupNumber and (goalTask.task or goalTask.endTask)
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

    @minMapTileY = @groupNumbers[@minGroupNumber].y - 6
    @maxMapTileY = @groupNumbers[@maxGroupNumber].y + 3
    @minMapTileX = -1
    @maxMapTileX = @levels[@maxLevel].exitTileX + 2
    @mapWidth = @maxMapTileX - @minMapTileX + 1
    @mapHeight = @maxMapTileY - @minMapTileY + 1

    # Create the tile map.
    @tileMap = {}

    for x in [@minMapTileX..@maxMapTileX]
      @tileMap[x] = {}

      for y in [@minMapTileY..@maxMapTileY]
        @tileMap[x][y] = {x, y}
        
    @tiles = []
    
    for y in [@minMapTileY..@maxMapTileY]
      for x in [@maxMapTileX..@minMapTileX]
        @tiles.push @tileMap[x][y]
        
    placeTile = (x, y, type, verticalBlueprintNeighbors = true) =>
      # Don't replace buildings and pathways.
      return if @tileMap[x][y].type in [@constructor.TileTypes.Building, @constructor.TileTypes.Sidewalk, @constructor.TileTypes.Road]
      
      # Placing a tile places that tile to the target and blueprints around it.
      @tileMap[x][y].type = type
      @tileMap[x - 1]?[y].type ?= @constructor.TileTypes.Blueprint
      @tileMap[x + 1]?[y].type ?= @constructor.TileTypes.Blueprint
      
      if verticalBlueprintNeighbors
        @tileMap[x][y - 1]?.type ?= @constructor.TileTypes.Blueprint
        @tileMap[x][y + 1]?.type ?= @constructor.TileTypes.Blueprint
    
    addAccessRoad = (x, endY) =>
      # Start from top-down, placing roads if there are none. If we hit a road, further places should be sidewalks.
      startY = @minMapTileY + 1
      sidewalk = false

      for y in [startY..endY]
        if @tileMap[x][y].type is @constructor.TileTypes.Road
          sidewalk = true
          
        else
          placeTile x, y, (if sidewalk then @constructor.TileTypes.Sidewalk else @constructor.TileTypes.Road), false
    
    # Place tasks.
    for goalTask in @goalTasks
      goalTask.tileY = @groupNumbers[goalTask.groupNumber].y - 1
      level = @levels[goalTask.level]
      
      goalTask.entryTile = @tileMap[level.entryTileX][goalTask.tileY + 1]
      goalTask.exitTile = @tileMap[level.exitTileX][goalTask.tileY + 1]
      
      # Connect entry tile and exit tile with a road.
      for x in [goalTask.entryTile.x..goalTask.exitTile.x]
        placeTile x, goalTask.entryTile.y, @constructor.TileTypes.Road
        
      # If it's not a dummy task, also place a building.
      if goalTask.task or goalTask.endTask
        placeTile goalTask.tileX, goalTask.tileY, @constructor.TileTypes.Building
    
      # Add ground.
      for x in [goalTask.tileX - 1..goalTask.tileX + 1]
        for y in [goalTask.tileY - 2..goalTask.tileY + 2]
          placeTile x, y, @constructor.TileTypes.Ground
    
    # Sort tasks back-to-front, right-to-left for correct z ordering.
    @sortedGoalTasks = _.orderBy @goalTasks, ['tileY', 'tileX'], ['asc', 'desc']
    
    onlyFinalTask = @goal.finalTasks()[0] if @goal.finalTasks().length is 1
    
    # Connect roads from all predecessors.
    for goalTask in @goalTasks
      for predecessor in goalTask.predecessors
        for y in [predecessor.exitTile.y..goalTask.entryTile.y]
          placeTile predecessor.exitTile.x, y, @constructor.TileTypes.Road
        
        groundMinY = Math.min(predecessor.exitTile.y, goalTask.entryTile.y) - 1
        groundMaxY = Math.max(predecessor.exitTile.y, goalTask.entryTile.y) + 1

        for y in [groundMinY..groundMaxY]
          for x in [predecessor.exitTile.x - 1..predecessor.exitTile.x + 1]
            placeTile x, y, @constructor.TileTypes.Ground
         
    # Create access roads.
    for goalTask in @goalTasks when goalTask.task
      # Add entry roads if there are required interests and we're not the first task of the goal.
      if goalTask.task.requiredInterests().length and goalTask.task.predecessors.length
        addAccessRoad(@levels[goalTask.level].entryTileX, goalTask.tileY)
        
      # Add exit roads if there are interests and we're not the only final task.
      if goalTask.task.interests().length and goalTask.task isnt onlyFinalTask
        addAccessRoad(@levels[goalTask.level].exitTileX, goalTask.tileY)
    
    # Determine road neighbors.
    for x in [@minMapTileX..@maxMapTileX]
      for y in [@minMapTileY..@maxMapTileY] when @tileMap[x][y].type is @constructor.TileTypes.Road
        left = @tileMap[x - 1]?[y]?.type is @constructor.TileTypes.Road
        right = @tileMap[x + 1]?[y]?.type is @constructor.TileTypes.Road
        up = @tileMap[x][y - 1]?.type is @constructor.TileTypes.Road
        down = @tileMap[x][y + 1]?.type is @constructor.TileTypes.Road
        @tileMap[x][y].neighbors = {left, right, up, down}
        
    # Place blueprint edges.
    for x in [@minMapTileX..@maxMapTileX]
      for y in [@minMapTileY..@maxMapTileY] when not @tileMap[x][y].type
        # One of the neighbors must have a defined type to be on the edge.
        upLeft = @tileMap[x - 1]?[y - 1]?.type
        up = @tileMap[x][y - 1]?.type
        upRight = @tileMap[x + 1]?[y - 1]?.type
        left = @tileMap[x - 1]?[y].type
        right = @tileMap[x + 1]?[y].type
        downLeft = @tileMap[x - 1]?[y + 1]?.type
        down = @tileMap[x][y + 1]?.type
        downRight = @tileMap[x + 1]?[y + 1]?.type
        continue unless upLeft or up or upRight or left or right or downLeft or down or downRight
        
        tile = @tileMap[x][y]
        tile.edge =
          left: upRight or right or downRight
          right: upLeft or left or downLeft
          up: downLeft or down or downRight
          down: upLeft or up or upRight
          
        # Opposite openings cancel each other.
        if tile.edge.left and tile.edge.right
          tile.edge.left = false
          tile.edge.right = false
          
        if tile.edge.up and tile.edge.down
          tile.edge.up = false
          tile.edge.down = false
          
        # If there are no edges left, we're inside of a hole and we should fill it.
        unless tile.edge.left or tile.edge.right or tile.edge.up or tile.edge.down
          tile.type = if left is @constructor.TileTypes.Ground and right is @constructor.TileTypes.Ground then @constructor.TileTypes.Ground else @constructor.TileTypes.Blueprint
          tile.edge = null
    
    @tileWidth = 8
    @tileHeight = 4
    @borderWidth = 1
    @padding =
      left: 6
      bottom: 6

    @requiredInterestsLabelHeight = 7
    @requiredInterestsMargin = 5

    # Optional interests are stated in two lines when no normal required interests are present.
    @optionalInterestsLabelHeight = if @goal.requiredInterests().length then 7 else 16

  onCreated: ->
    super arguments...

    @display = LOI.adventure.interface.display

    @nameHeight = new ReactiveField 20
    @requiredInterestsPositionsById = new ReactiveField null
    @requiredInterestsHeight = new ReactiveField null
    @optionalInterestsTop = new ReactiveField null

    # Subscribe to all interests of this goal.
    @autorun (computation) =>
      for interest in _.union @goal.interests(), @goal.requiredInterests(), @goal.optionalInterests()
        IL.Interest.forSearchTerm.subscribe interest

  onRendered: ->
    super arguments...

    # Update name height when in blueprint.
    @autorun (computation) =>
      # Depend on goal name and scale.
      @goal.displayName()
      scale = @display.scale()

      # Measure name height after it had a chance to update.
      Meteor.setTimeout =>
        # HACK: Also make sure the elements are being rendered since they will return 0 otherwise.
        requestAnimationFrame =>
          @nameHeight @$('.pixelartacademy-pixelpad-apps-studyplan-goal > .name').outerHeight() / scale
      ,
        0

    # Update required interests positions.
    @autorun (computation) =>
      scale = @display.scale()

      # Depend on names of interests.
      for interest in [@goal.requiredInterests()..., @goal.optionalInterests()...]
        continue unless interestDocument = IL.Interest.find interest

        AB.translate interestDocument.name

      # Measure name heights after they had a chance to update.
      Meteor.setTimeout =>
        requestAnimationFrame =>
          positions = {}
          top = 0

          analyzeInterests = ($interests) =>
            for interest in $interests
              $interest = $(interest)
              id = $interest.data 'id'

              top += @requiredInterestsMargin
              positions[id] = top

              # Move down by the title height.
              height = $interest.outerHeight() / scale
              top += height

          $requiredInterests = @$('.required-interests .interest')
          analyzeInterests $requiredInterests

          # If any interests were found, also accommodate the required label.
          top += @requiredInterestsMargin + @requiredInterestsLabelHeight if $requiredInterests.length

          @optionalInterestsTop top

          $optionalInterests = @$('.optional-interests .interest')
          analyzeInterests $optionalInterests

          # If any optional interests were found, also accommodate the optional label.
          top += @requiredInterestsMargin + @optionalInterestsLabelHeight if $optionalInterests.length

          @requiredInterestsPositionsById positions
          @requiredInterestsHeight top
      ,
        0

  goalStyle: ->
    return @contractedGoalStyle() unless @state and @blueprint

    # Make sure we have position present, as it will disappear when goal is being deleted.
    return @contractedGoalStyle() unless position = @position()

    scale = @blueprint.camera().scale()

    position: 'absolute'
    left: "#{position.x * scale}rem"
    top: "#{position.y * scale}rem"
    width: "#{@goalWidth()}rem"
    height: "#{@goalHeight()}rem"

  contractedGoalStyle: ->
    width: "#{@goalWidth()}rem"
    height: "#{@goalHeight()}rem"

  goalWidth: ->
    @padding.left + @tasksMapSize().width + 2 * @borderWidth

  goalHeight: ->
    collapsedHeight = @nameHeight() + 2 * @borderWidth

    return collapsedHeight unless @expanded?()

    _.sum [
      collapsedHeight
      @tasksMapSize().height
      @requiredInterestsHeight()
      @padding.bottom
    ]

  expandedClass: ->
    'expanded' if @expanded?()

  showRequiredInterests: ->
    # Show required interests when you have all the interest documents.
    return unless requiredInterests = @goal.requiredInterests()
    return unless requiredInterests.length

    for interest in requiredInterests
      return unless IL.Interest.find interest

    true

  showOptionalInterests: ->
    # Show optional interests when you have all the interest documents.
    return unless optionalInterests = @goal.optionalInterests()
    return unless optionalInterests.length

    for interest in optionalInterests
      return unless IL.Interest.find interest

    true

  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest

  requiredInterestEntryPointById: (interestId) ->
    if @expanded()
      return unless @isCreated()
      return unless requiredInterestsPositionsById = @requiredInterestsPositionsById()
      return unless taskMapSize = @tasksMapSize()
      return unless requiredInterestPosition = requiredInterestsPositionsById[interestId]

      top = Math.ceil @nameHeight() + taskMapSize.height + @requiredInterestsMargin + @requiredInterestsLabelHeight + requiredInterestPosition

      y = top + Math.ceil @taskHeight / 2

    else
      y = @nameHeight() / 2

    x: -1
    y: y

  validTargetClass: ->
    interestDocument = @currentData()

    draggedInterestIds = @blueprint?.draggedInterestIds()
    return unless draggedInterestIds?.length

    if interestDocument._id in @blueprint.draggedInterestIds() then 'valid-target' else 'invalid-target'

  tasksMapSize: ->
    minimumWidth = @mapWidth * @tileWidth + @mapHeight * @tileHeight

    width: Math.max 80, minimumWidth
    height: @mapHeight * @tileHeight

  tasksMapStyle: ->
    tasksMapSize = @tasksMapSize()

    top: "#{@nameHeight()}rem"
    left: "#{@padding.left}rem"
    width: "#{tasksMapSize.width}rem"
    height: "#{tasksMapSize.height}rem"

  tileTypeClasses: ->
    tile = @currentData()
    
    classes = [_.kebabCase tile.type]

    if tile.edge
      classes.push 'edge'
      
      for side, edgeExits of tile.edge when edgeExits
        classes.push side
    
    if tile.type is @constructor.TileTypes.Road
      for side, neighborExists of tile.neighbors when neighborExists
        classes.push side
    
    classes.join ' '
  
  tileStyle: ->
    tile = @currentData()
    position = @_mapPosition tile.x, tile.y
    
    left: "#{position.x}rem"
    top: "#{position.y}rem"
    
  taskStyle: ->
    goalTask = @currentData()
    position = @_mapPositionForGoalTask goalTask

    left: "#{position.x}rem"
    top: "#{position.y}rem"
    
  _mapPosition: (tileX, tileY) ->
    relativeX = tileX - @minMapTileX
    relativeY = tileY - @minMapTileY
    
    x: relativeX * @tileWidth + relativeY * @tileHeight
    y: relativeY * @tileHeight
    
  _mapPositionForGoalTask: (goalTask) ->
    @_mapPosition goalTask.tileX, goalTask.tileY
  
  completeFlagStyle: ->
    position = @_mapPositionForGoalTask @endGoalTask
    left: "#{position.x}rem"
    top: "#{position.y}rem"

  providedInterestsPosition: ->
    if @expanded?()
      y = @nameHeight() + @_mapPositionForGoalTask(@endGoalTask).y

    else
      y = @nameHeight() / 2 - @taskHeight / 2

    x: @goalWidth() - @borderWidth - Math.ceil @taskWidth / 2
    y: y

  providedInterestsStyle: ->
    position = @providedInterestsPosition()
  
    left: "#{position.x}rem"
    top: "#{position.y}rem"
    width: "#{@taskWidth}rem"
    height: "#{@taskHeight}rem"

  providedInterestsExitPoint: ->
    return unless @isCreated()

    if @expanded()
      y = @nameHeight() + @endGoalTask.exitTile.y

    else
      y = @nameHeight() / 2

    x: @goalWidth()
    y: y + 1

  requiredInterestsLabelStyle: ->
    top = @nameHeight() + @tasksMapSize().height + @requiredInterestsMargin

    top: "#{top}rem"

  optionalInterestsLabelStyle: ->
    top = @nameHeight() + @tasksMapSize().height + @requiredInterestsMargin + @optionalInterestsTop()

    top: "#{top}rem"

  requiredInterestStyle: ->
    interestDocument = @currentData()
    return unless requiredInterestsPositionsById = @requiredInterestsPositionsById()

    requiredInterestsPosition = requiredInterestsPositionsById[interestDocument._id]
    top = _.sum [
      @nameHeight()
      @tasksMapSize().height
      @requiredInterestsMargin
      @requiredInterestsLabelHeight
      requiredInterestsPosition
    ]

    top: "#{top}rem"

  optionalInterestStyle: ->
    interestDocument = @currentData()
    return unless requiredInterestsPositionsById = @requiredInterestsPositionsById()

    requiredInterestsPosition = requiredInterestsPositionsById[interestDocument._id]
    top = _.sum [
      @nameHeight()
      @tasksMapSize().height
      @requiredInterestsMargin
      @optionalInterestsLabelHeight
      requiredInterestsPosition
    ]

    top: "#{top}rem"

  events: ->
    super(arguments...).concat
      'mousedown .pixelartacademy-pixelpad-apps-studyplan-goal': @onMouseDownGoal
      'click .pixelartacademy-pixelpad-apps-studyplan-goal > .name': @onClickName
      'click .required-interests .interest': @onClickRequiredInterest
      'mousedown .required-interests .interest .connector': @onMouseDownRequiredInterestConnector
      'mouseup .required-interests .interest': @onMouseUpRequiredInterest
      'mouseenter .required-interests .interest': @onMouseEnterRequiredInterest
      'mouseleave .required-interests .interest': @onMouseLeaveRequiredInterest
      'mousedown .provided-interests': @onMouseDownProvidedInterests

  onMouseDownGoal: (event) ->
    # We only deal with drag & drop for goals inside the canvas.
    return unless @blueprint
    
    # Prevent browser select/dragging behavior
    event.preventDefault()
    
    @blueprint.startDrag
      goalId: @goal.id()
      goalPosition: @position()

  onClickName: (event) ->
    return unless @expanded

    @expanded not @expanded()

  onClickRequiredInterest: (event) ->
    interestDocument = @currentData()

    @blueprint.studyPlan.goalSearch().setInterest interestDocument

  onMouseDownRequiredInterestConnector: (event) ->
    interestDocument = @currentData()

    # Prevent selection.
    event.preventDefault()

    # Prevent goal drag.
    event.stopPropagation()

    @blueprint.modifyConnection
      goalId: @goal.id()
      interest: interestDocument.referenceString()

  onMouseUpRequiredInterest: (event) ->
    interestDocument = @currentData()

    @blueprint.endConnection
      goalId: @goal.id()
      interest: interestDocument.referenceString()

  onMouseEnterRequiredInterest: (event) ->
    interestDocument = @currentData()

    @blueprint.startHoverInterest
      goalId: @goal.id()
      interest: interestDocument.referenceString()

  onMouseLeaveRequiredInterest: (event) ->
    @blueprint.endHoverInterest()

  onMouseDownProvidedInterests: (event) ->
    # Prevent selection.
    event.preventDefault()
    
    # Prevent goal drag.
    event.stopPropagation()

    @blueprint.startConnection @goal.id()
