AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Goal'
  @register @id()

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
      goalTask.level = null for goalTask in @goalTasks
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

    @taskWidth = 9
    @taskHeight = 9
    @levelGap = 8
    @groupGap = 6
    @borderWidth = 1
    @padding =
      left: 6
      bottom: 6

    @requiredInterestsLabelHeight = 7
    @requiredInterestsMargin = 5

    # Optional interests are stated in two lines when no normal required interests are present.
    @optionalInterestsLabelHeight = if @goal.requiredInterests().length then 7 else 16

    # Calculate entry and exit points.
    for goalTask in @goalTasks
      position = @_taskPosition goalTask

      goalTask.entryPoint =
        x: position.x
        y: position.y + Math.floor @taskHeight / 2

      goalTask.exitPoint =
        x: position.x + @taskWidth
        y: position.y + Math.floor @taskHeight / 2

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

    # Draw tasks map connections.
    @constructor.TasksMapConnections.draw @

    # Update name height when in blueprint.
    @autorun (computation) =>
      # Depend on goal name and scale.
      @goal.displayName()
      scale = @display.scale()

      # Measure name height after it had a chance to update.
      Meteor.setTimeout =>
        # HACK: Also make sure the elements are being rendered since they will return 0 otherwise.
        requestAnimationFrame =>
          @nameHeight @$('.pixelartacademy-pixelboy-apps-studyplan-goal > .name').outerHeight() / scale
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
    minimumWidth = @levelsCount * @taskWidth + (@levelsCount - 1) * @levelGap - Math.ceil @taskWidth / 2

    width: Math.max 80, minimumWidth
    height: @groupsCount * @taskHeight + (@groupsCount - 1) * @groupGap

  tasksMapStyle: ->
    tasksMapSize = @tasksMapSize()

    top: "#{@nameHeight()}rem"
    left: "#{@padding.left}rem"
    width: "#{tasksMapSize.width}rem"
    height: "#{tasksMapSize.height}rem"

  taskStyle: ->
    goalTask = @currentData()
    position = @_taskPosition goalTask

    left: "#{position.x}rem"
    top: "#{position.y}rem"
    width: "#{@taskWidth}rem"
    height: "#{@taskHeight}rem"
    
  _taskPosition: (goalTask) ->
    x: goalTask.level * (@taskWidth + @levelGap)
    y: (goalTask.groupNumber - @minGroupNumber) * (@taskHeight + @groupGap)

  providedInterestsPosition: ->
    if @expanded?()
      y = @nameHeight() + @_taskPosition(@endGoalTask).y

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
      y = @nameHeight() + @endGoalTask.exitPoint.y

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
      'mousedown .pixelartacademy-pixelboy-apps-studyplan-goal': @onMouseDownGoal
      'click .pixelartacademy-pixelboy-apps-studyplan-goal > .name': @onClickName
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
