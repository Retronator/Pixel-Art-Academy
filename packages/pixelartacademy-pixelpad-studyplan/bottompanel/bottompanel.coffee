AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.BottomPanel extends AM.Component
  constructor: (@studyPlan) ->
    super arguments...

    @headerHeight = 15
    
    @opened = new ReactiveField false

  onCreated: ->
    super arguments...

    @contentHeight = new ReactiveField 0
    @previousContentHeight = new ReactiveField 0

    @addedTaskClasses = new ComputedField =>
      return unless goals = StudyPlan.state 'goals'

      _.flatten (for goalId of goals
        continue unless goalClass = PAA.Learning.Goal.getClassForId goalId
        goalClass.tasks()
      )

  onRendered: ->
    super arguments...

    @$content = @$('.content')
    @_resizeObserver = new ResizeObserver =>
      @previousContentHeight @contentHeight()
      @contentHeight @$content.outerHeight()

    @_resizeObserver.observe @$content[0]

  onDestroyed: ->
    super arguments...

    @_interestFocusRequest = null
    @_resizeObserver?.disconnect()

  open: ->
    @opened true

  close: ->
    @opened false

  containerStyle: ->
    maxContentHeight = Math.max @contentHeight(), @previousContentHeight()

    height: "#{maxContentHeight}px"

  panelStyle: ->
    if @opened()
      bottom: "#{@contentHeight()}px"

    else
      bottom: 0

  events: ->
    super(arguments...).concat
      'click .title': @onClickTitle
      'click .interest': @onClickInterest
      'pointerleave .interest': @onPointerLeaveInterest

  onClickTitle: (event) ->
    @opened not @opened()

  onClickInterest: (event) ->
    interest = @currentData()

    possibleTaskClasses = _.filter @addedTaskClasses(), (taskClass) => interest.referenceName in taskClass.interests()
    return unless possibleTaskClasses.length

    if @_lastFocusedTask in possibleTaskClasses
      # Cycle through possible task classes.
      index = possibleTaskClasses.indexOf @_lastFocusedTask
      taskClass = possibleTaskClasses[(index + 1) % possibleTaskClasses.length]

    else
      taskClass = possibleTaskClasses[0]

    @_lastFocusedTask = taskClass
    taskId = @_lastFocusedTask.id()

    # Create a dummy object that represents this click request.
    interestFocusRequest = {}
    @_interestFocusRequest = interestFocusRequest

    # Return back to the main view if anything was selected and wait until map bounds update.
    @studyPlan.deselectGoal()
    @studyPlan.deselectTask()
    @studyPlan.stopHighlightingTask()
    await _.waitForFlush()
    
    # Make sure we're still on the same request.
    return unless @_interestFocusRequest is interestFocusRequest

    # Animate to new location and wait before highlighting the task so task info appears when camera has stopped.
    animationCompleted = await @studyPlan.blueprint().focusTask taskId
    return unless animationCompleted and @_interestFocusRequest is interestFocusRequest

    @studyPlan.highlightTask taskId

  onPointerLeaveInterest: (event) ->
    # Leaving the interest also cancels any highlight waiting for the camera to arrive.
    @_interestFocusRequest = null
    @studyPlan.stopHighlightingTask()
