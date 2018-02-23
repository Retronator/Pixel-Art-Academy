AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Goal'
  @register @id()

  constructor: (goalOrOptions) ->
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

    # Create goal tasks that we can attach extra info to.
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

    calculateLevel goalTask for goalTask in @goalTasks

    # Create dummy goal tasks in missing levels.
    for goalTask in @goalTasks
      # Go over the predecessors, but clone them since we'll be mutating the array.
      for predecessor in _.clone goalTask.predecessors when predecessor.level < goalTask.level - 1
        lastGoalTask = predecessor
        for missingLevel in [predecessor.level + 1...goalTask.level]
          # Create the dummy goal in the same group as the predecessor and link it to the previous missing level.
          lastGoalTask =
            level: missingLevel
            groupNumber: predecessor.groupNumber
            predecessors: [lastGoalTask]

        # Link this goalTask's predecessor to the missing level.
        _.pull goalTask.predecessors, predecessor
        goalTask.predecessors.push lastGoalTask

    @minGroupNumber = _.min _.map @goalTasks, 'groupNumber'
    @maxGroupNumber = _.max _.map @goalTasks, 'groupNumber'
    @maxLevel = _.max _.map @goalTasks, 'level'
    @levelsCount = @maxLevel + 1
    @groupsCount = @maxGroupNumber - @minGroupNumber + 1

    @taskWidth = 9
    @taskHeight = 9
    @levelGap = 9
    @groupGap = 7
    
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
    super

    # Subscribe to all interests of this goal.
    @autorun (computation) =>
      for interest in _.union @goal.interests(), @goal.requiredInterests()
        IL.Interest.forSearchTerm.subscribe interest
        
  onRendered: ->
    super
    
    # Draw tasks map connections.
    @constructor.TasksMapConnections.draw @

  goalStyle: ->
    return unless @state and @blueprint

    # Make sure we have position present, as it will disappear when goal is being deleted.
    return unless position = @position()

    scale = @blueprint.camera().scale()

    width = _.min 100, @tasksMapSize().width + 20

    position: 'absolute'
    left: "#{position.x * scale}rem"
    top: "#{position.y * scale}rem"
    width: "#{width}rem"

  expandedClass: ->
    'expanded' if @expanded?()

  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest

  $getConnectorByRequiredInterestId: (id) ->
    $interest = @$(".required-interests .interest[data-id='#{id}'] .connector")
    return $interest if $interest.length

    # HACK: Seems like the interest isn't rendered yet. Force a reactive recomputation after a delay.
    dependency = new Tracker.Dependency
    dependency.depend()

    Meteor.setTimeout =>
      dependency.changed()
    ,
      100

  validTargetClass: ->
    interestDocument = @currentData()

    draggedInterestIds = @blueprint.draggedInterestIds()
    return unless draggedInterestIds.length

    if interestDocument._id in @blueprint.draggedInterestIds() then 'valid-target' else 'invalid-target'

  tasksMapSize: ->
    width: @levelsCount * @taskWidth + (@levelsCount - 1) * @levelGap
    height: @groupsCount * @taskHeight + (@groupsCount - 1) * @groupGap

  tasksMapStyle: ->
    tasksSize = @tasksMapSize()

    width: "#{tasksSize.width}rem"
    height: "#{tasksSize.height}rem"

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

  events: ->
    super.concat
      'mousedown .pixelartacademy-pixelboy-apps-studyplan-goal': @onMouseDownGoal
      'click .pixelartacademy-pixelboy-apps-studyplan-goal > .name': @onClickName
      'click .required-interests .interest': @onClickRequiredInterest
      'mousedown .required-interests .interest': @onMouseDownRequiredInterest
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

  onMouseDownRequiredInterest: (event) ->
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
