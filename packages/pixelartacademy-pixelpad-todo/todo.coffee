AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.ToDo extends PAA.PixelPad.System
  @id: -> 'PixelArtAcademy.PixelPad.Systems.ToDo'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "To-do"
  @description: ->
    "
      The task-tracking information system.
    "

  @initialize()
  
  @DisplayState =
    Open: 'Open'
    Closed: 'Closed'
    Hidden: 'Hidden'
  
  constructor: ->
    super arguments...
    
    @bindingHeight = 14
    @hideTop = 30
    
    @waitBetweenAnimationsDuration = 0.3
    @animationStepDuration = 0.03
  
  onCreated: ->
    super arguments...
    
    @mouseHovering = new ReactiveField false
    
    @selectedTask = new ReactiveField null
    @contentHeight = new ReactiveField 0
    @previousContentHeight = new ReactiveField 0
  
    @manualDisplayState = new ReactiveField null

    @defaultDisplayState = new ComputedField => if @os.currentAppUrl() then @constructor.DisplayState.Hidden else @constructor.DisplayState.Closed

    @displayState = new ComputedField =>
      # Automatically hide if an app is loaded.
      return @constructor.DisplayState.Hidden if @os.currentAppUrl()
      
      @manualDisplayState() or @defaultDisplayState()
  
    # Automatically deselect the task when not open.
    @autorun (computation) =>
      return if @displayState() is @constructor.DisplayState.Open

      @selectedTask null
  
    @tasks = new ComputedField =>
      _.flatten (chapter.tasks for chapter in LOI.adventure.currentChapters())
  
    @activeTasks = new ComputedField =>
      _.filter @tasks(), (task) => task.active()
      
    @completedTasks = new ReactiveField []
    @displayedActiveTasks = new ReactiveField []
  
    @autorun (computation) =>
      completedTasks = Tracker.nonreactive => @completedTasks()
  
      completedTasks.push task for task in @displayedActiveTasks() when task.completed() and task not in completedTasks
      
      @completedTasks completedTasks

  onRendered: ->
    super arguments...
    
    @content$ = @$('.content')
    @_resizeObserver = new ResizeObserver =>
      @previousContentHeight @contentHeight()
      @contentHeight @content$.outerHeight()
    
    @_resizeObserver.observe @content$[0]
  
    @animating = new ReactiveField false
    
    @$displayedTasks = @$('.displayed-tasks')
    
    @autorun (computation) =>
      # Animate the next task if we're idle and visible.
      return if @animating()
      return if @selectedTask()
      return if @displayState() is @constructor.DisplayState.Hidden
    
      # Mark completed tasks.
      displayedActiveTasks = @displayedActiveTasks()
    
      for task in displayedActiveTasks
        if task.completed()
          @_animateTaskCompleted task
          return
          
      for task in @activeTasks() when task not in displayedActiveTasks
        @_animateTaskAdded task
        return
        
  _animationAvailable: ->
    # If any of the displayed tasks have completed, we should animate.
    displayedActiveTasks = @displayedActiveTasks()
    return true for task in displayedActiveTasks when task.completed()
    
    # If any of the active tasks is not displayed, we should animate.
    return true for task in @activeTasks() when task not in displayedActiveTasks
  
  _animateTaskCompleted: (task) ->
    @animating true
    
    await @_animateOpen()
    
    $taskListItem = $("[data-task-id='#{task.id()}']")
    directive = task.directive()
  
    for i in [0..directive.length]
      $taskListItem.html "<span class='directive'><span class='crossed-off'>#{directive[..i]}</span>#{directive[i+1..]}</span>"
      await _.waitForSeconds @animationStepDuration
      
    $taskListItem.removeClass('active').addClass('completed')
  
    displayedActiveTasks = @displayedActiveTasks()
    _.pull displayedActiveTasks, task
    @displayedActiveTasks displayedActiveTasks
  
    await _.waitForSeconds @waitBetweenAnimationsDuration
  
    @animating false
    
    @_animateClose()
  
  _animateTaskAdded: (task) ->
    @animating true
  
    await @_animateOpen()
    
    displayedActiveTasks = @displayedActiveTasks()
    displayedActiveTasks.push task
    @displayedActiveTasks displayedActiveTasks
    
    $taskListItem = $("<li class='task' data-task-id='#{task.id()}'>")
    @$displayedTasks.append $taskListItem
  
    directive = task.directive()
    
    for i in [0..directive.length]
      $taskListItem.html "<span class='directive'>#{directive[..i]}<span style='visibility: hidden'>#{directive[i+1..]}</span></span>"
      await _.waitForSeconds @animationStepDuration
    
    $taskListItem.addClass('active')

    await _.waitForSeconds @waitBetweenAnimationsDuration
    
    @_animateClose()

    @animating false

  _animateOpen: ->
    @selectedTask null
    
    return if @displayState() is @constructor.DisplayState.Open
  
    # Give some time for the other UI animations to finish.
    await _.waitForSeconds 1.2
  
    @manualDisplayState @constructor.DisplayState.Open
    
    await _.waitForSeconds 1
    
  _animateClose: ->
    Meteor.clearTimeout @_animateCloseTimeout
    
    # Close after a second if no further animations are happening.
    @_animateCloseTimeout = Meteor.setTimeout =>
      return if @animating()
      
      return if @mouseHovering()
      
      @manualDisplayState null
    ,
      2000
    
  onBackButton: ->
    # If we have an animation waiting to happen, we want the back button to return us to the main menu.
    return unless @_animationAvailable()
    
    parameter1 = AB.Router.getParameter 'parameter1'
    AB.Router.setParameters {parameter1}
  
    # Inform that we've handled the back button.
    true
    
  displayStateClass: ->
    _.kebabCase @displayState()
  
  notepadStyle: ->
    switch @displayState()
      when @constructor.DisplayState.Open
        top = "calc(-#{@contentHeight()}px - #{@bindingHeight}rem)"
        
      when @constructor.DisplayState.Closed
        top = "-#{@bindingHeight - 1}rem"
        
      else
        top = "#{@hideTop}rem"
  
    {top}
    
  pageStyle: ->
    maxContentHeight = Math.max @contentHeight(), @previousContentHeight()

    height: "#{maxContentHeight}px"
  
  showToDo: ->
    @activeTasks() or @completedTasks()

  taskSelectedClass: ->
    'task-selected' if @selectedTask()
  
  events: ->
    super(arguments...).concat
      'click': @onClick
      'mouseenter .pixelartacademy-pixelpad-systems-todo': @onMouseEnterToDo
      'mouseleave .pixelartacademy-pixelpad-systems-todo': @onMouseLeaveToDo
      'click .binding': @onClickBinding
      'click .task': @onClickTask
      'click .back-button': @onClickBackButton
    
  onClick: (event) ->
    Meteor.clearTimeout @_animateCloseTimeout
    
  onMouseEnterToDo: (event) ->
    @mouseHovering true

  onMouseLeaveToDo: (event) ->
    @mouseHovering false

  onClickBinding: (event) ->
    defaultDisplayState = @defaultDisplayState()
    
    if defaultDisplayState is @constructor.DisplayState.Hidden
      @manualDisplayState null
      
    else
      targetDisplayState = if @displayState() is @constructor.DisplayState.Open then @constructor.DisplayState.Closed else @constructor.DisplayState.Open
      @manualDisplayState if targetDisplayState is defaultDisplayState then null else targetDisplayState
    
  onClickTask: (event) ->
    taskId = $(event.target).closest('.task').data('taskId')
    
    @selectedTask _.find @tasks(), (task) => task.id() is taskId
  
  onClickBackButton: (event) ->
    @selectedTask null
