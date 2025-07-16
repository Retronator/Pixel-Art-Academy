AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
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
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      open: AEc.ValueTypes.Trigger
      close: AEc.ValueTypes.Trigger
      pageFlip: AEc.ValueTypes.Trigger
      notepadPan: AEc.ValueTypes.Number
      writing: AEc.ValueTypes.Boolean
      writingPan: AEc.ValueTypes.Number
      strikethrough: AEc.ValueTypes.Boolean
  
  constructor: ->
    super arguments...
    
    @bindingHeight = 14
    @hideTop = 40
    
    @waitBetweenAnimationsDuration = 0.1
    @animationStepDuration = 0.02
  
  onCreated: ->
    super arguments...
    
    @mouseHovering = new ReactiveField false
    @openButtonHovering = new ReactiveField false
    
    @selectedTask = new ReactiveField null
    @contentHeight = new ReactiveField 0
    @previousContentHeight = new ReactiveField 0
  
    @manualDisplayState = new ReactiveField null

    @defaultDisplayState = new ComputedField => if @os.currentAppUrl() then @constructor.DisplayState.Hidden else @constructor.DisplayState.Closed

    @displayState = new ComputedField =>
      @manualDisplayState() or @defaultDisplayState()
      
    # Automatically hide if an app is loaded.
    @autorun (computation) =>
      @manualDisplayState null if @os.currentAppUrl()
  
    # Automatically deselect the task when not open.
    @autorun (computation) =>
      return if @displayState() is @constructor.DisplayState.Open

      @selectedTask null
  
    # Handle displayed tasks.
    @tasks = new ComputedField =>
      _.flatten (chapter.tasks for chapter in LOI.adventure.currentChapters())
  
    @activeTasks = new ComputedField =>
      _.filter @tasks(), (task) => task.active()

    @activeTasksToBeDisplayed = new ReactiveField []
    @displayedActiveTasks = new ReactiveField []
    @completedTasks = new ReactiveField []
    
    @autorun (computation) =>
      activeTasks = @activeTasks()
      
      Tracker.nonreactive =>
        activeTasksToBeDisplayed = @activeTasksToBeDisplayed()
        displayedActiveTasks = @displayedActiveTasks()
        completedTasks = @completedTasks()
        
        activeTasksToBeDisplayed.push task for task in activeTasks when task not in activeTasksToBeDisplayed and task not in displayedActiveTasks
        
        @activeTasksToBeDisplayed activeTasksToBeDisplayed
        
        # Remove completed tasks so that the total shown tasks is not above 9 if possible.
        tasksCount = activeTasksToBeDisplayed.length + displayedActiveTasks.length + completedTasks.length
        removeCount = tasksCount - 9
        return unless removeCount > 0
        
        removedTasks = completedTasks.splice 0, removeCount
        @completedTasks completedTasks
        
        # Also remove them from the displayed list.
        for task in removedTasks
          @$("[data-task-id='#{task.id()}']").remove()

  onRendered: ->
    super arguments...
    
    @$content = @$('.page .content')
    @_resizeObserver = new ResizeObserver =>
      @previousContentHeight @contentHeight()
      @contentHeight @$content.outerHeight()
    
    @_resizeObserver.observe @$content[0]
  
    @animating = new ReactiveField false
    
    @$displayedTasks = @$('.displayed-tasks')
    
    @autorun (computation) =>
      # Animate the next task if we're idle and visible.
      return if @animating()
      return if @selectedTask()
      return if @displayState() is @constructor.DisplayState.Hidden
      return if LOI.adventure.modalDialogs().length
    
      # Mark completed tasks.
      displayedActiveTasks = @displayedActiveTasks()
    
      for task in displayedActiveTasks
        if task.completed()
          @_animateTaskCompleted task
          return
          
      # Add new tasks.
      for task in @activeTasksToBeDisplayed()
        @_animateTaskAdded task
        return
    
    Tracker.triggerOnDefinedChange @displayState, (displayState, previousDisplayState) =>
      # Make sure we're still being rendered.
      return unless @isRendered()
    
      @_updateNotepadPan()
      
      if displayState is @constructor.DisplayState.Open
        @audio.open()
      
      else if displayState is @constructor.DisplayState.Closed and previousDisplayState is @constructor.DisplayState.Open
        @audio.close()
        
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver?.disconnect()
    
    # Disable any ongoing audio.
    @audio.strikethrough false
    @audio.writing false
    
  _animationAvailable: ->
    # If any of the displayed tasks have completed, we should animate.
    displayedActiveTasks = @displayedActiveTasks()
    return true for task in displayedActiveTasks when task.completed()
    
    # If any of the active tasks is not displayed, we should animate.
    return true for task in @activeTasks() when task not in displayedActiveTasks
  
  _animateTaskCompleted: (task) ->
    return unless await @_animateOpen()
    
    $taskListItem = @$("[data-task-id='#{task.id()}']")
    directive = task.directive()
    
    @audio.strikethrough true
  
    for i in [0..directive.length]
      $taskListItem.html "<span class='directive'><span class='crossed-off'>#{directive[..i]}</span><span class='cursor'></span>#{directive[i+1..]}</span>"
      @_updateWritingPan()
      await _.waitForSeconds @animationStepDuration
      
    $taskListItem.removeClass('active').addClass('completed')
    
    @audio.strikethrough false

    displayedActiveTasks = @displayedActiveTasks()
    completedTasks = @completedTasks()

    _.pull displayedActiveTasks, task
    completedTasks.push task

    @displayedActiveTasks displayedActiveTasks
    @completedTasks completedTasks
  
    await _.waitForSeconds @waitBetweenAnimationsDuration

    await task.onCompletedDisplayed()
    
    @_animateClose()
  
  _animateTaskAdded: (task) ->
    return unless await @_animateOpen()
    
    activeTasksToBeDisplayed = @activeTasksToBeDisplayed()
    displayedActiveTasks = @displayedActiveTasks()
    
    _.pull activeTasksToBeDisplayed, task
    displayedActiveTasks.push task
    
    @activeTasksToBeDisplayed activeTasksToBeDisplayed
    @displayedActiveTasks displayedActiveTasks
    
    $taskListItem = $("<li class='task' data-task-id='#{task.id()}'>")
    @$displayedTasks.append $taskListItem
  
    directive = task.directive()
    
    @audio.writing true
    
    for i in [0..directive.length]
      $taskListItem.html "<span class='directive'>#{directive[..i]}<span class='cursor'></span><span style='visibility: hidden'>#{directive[i+1..]}</span></span>"
      @_updateWritingPan()
      await _.waitForSeconds @animationStepDuration
    
    $taskListItem.addClass('active')
    
    @audio.writing false

    await _.waitForSeconds @waitBetweenAnimationsDuration
  
    await task.onActiveDisplayed()
  
    @_animateClose()
    
  _updateWritingPan: ->
    # Make sure the cursor is still rendered.
    return unless cursor = @$('.cursor')?[0]
    
    @audio.writingPan AEc.getPanForElement cursor

  _animateOpen: ->
    @animating true
  
    @selectedTask null
    
    unless @displayState() is @constructor.DisplayState.Open
      # Give some time for the other UI animations to finish.
      await _.waitForSeconds 1
      
      # Make sure we're still on the home screen (no app has been opened while we were waiting).
      if @os.currentAppUrl()
        @animating false
        return false
      
      @manualDisplayState @constructor.DisplayState.Open
      
      await _.waitForSeconds 0.35
    
    # Make sure we're still being rendered.
    unless @isRendered()
      @animating false
      return false
    
    true
  
  _animateClose: ->
    @animating false
    
    Meteor.clearTimeout @_animateCloseTimeout
    
    # Close after a second if no further animations are happening.
    @_animateCloseTimeout = Meteor.setTimeout =>
      return if @animating()
      
      return if @mouseHovering()
      
      @manualDisplayState null
    ,
      2000
      
  allowsShortcutsTable: -> false
  
  onBackButton: ->
    # If we have an animation waiting to happen, we want any presses on the back button
    # to return us to the main menu so that the to-do tasks can be visually updated.
    return unless @_animationAvailable()
    
    parameter1 = AB.Router.getParameter 'parameter1'
    AB.Router.setParameters {parameter1}
  
    # Inform that we've handled the back button.
    true
    
  isActive: ->
    @isRendered() and @animating() or @displayState() is @constructor.DisplayState.Open
    
  waitUntilInactive: ->
    new Promise (resolve, reject) =>
      Tracker.autorun (computation) =>
        return if @isActive()
        computation.stop()
        resolve()
        
  close: -> @manualDisplayState null
  
  notifications: -> @os.getSystem PAA.PixelPad.Systems.Notifications

  displayStateClass: ->
    _.kebabCase @displayState()
    
  openButtonHoveredClass: ->
    'open-button-hovered' if @openButtonHovering()
    
  selectedTaskVisibleClass: ->
    'selected-task-visible' if @selectedTask()
  
  notepadStyle: ->
    switch @displayState()
      when @constructor.DisplayState.Open
        top = "calc(-#{@contentHeight()}px - #{@bindingHeight}rem)"
        
      when @constructor.DisplayState.Closed
        top = "-#{@bindingHeight + if @openButtonHovering() then 3 else -1}rem"
        
      else
        top = "#{@hideTop}rem"
  
    {top}
    
  pageStyle: ->
    maxContentHeight = Math.max @contentHeight(), @previousContentHeight()

    # Add 10% to account for the bounce animation.
    height: "#{maxContentHeight * 1.1}px"
  
  showToDo: ->
    @activeTasks().length or @completedTasks().length or @displayedActiveTasks().length

  taskSelectedClass: ->
    'task-selected' if @selectedTask()
  
  events: ->
    super(arguments...).concat
      'click': @onClick
      'mouseenter .pixelartacademy-pixelpad-systems-todo': @onMouseEnterToDo
      'mouseleave .pixelartacademy-pixelpad-systems-todo': @onMouseLeaveToDo
      'mouseenter .open-button': @onMouseEnterOpenButton
      'mouseleave .open-button': @onMouseLeaveOpenButton
      'click .open-button': @onClickOpenButton
      'click .task': @onClickTask
      'click .back-button': @onClickBackButton
    
  onClick: (event) ->
    Meteor.clearTimeout @_animateCloseTimeout
    
  onMouseEnterToDo: (event) ->
    @mouseHovering true

  onMouseLeaveToDo: (event) ->
    @mouseHovering false

  onMouseEnterOpenButton: (event) ->
    @openButtonHovering true
  
  onMouseLeaveOpenButton: (event) ->
    @openButtonHovering false
  
  onClickOpenButton: ->
    defaultDisplayState = @defaultDisplayState()
    
    if defaultDisplayState is @constructor.DisplayState.Hidden
      @manualDisplayState null
      
    else
      targetDisplayState = if @displayState() is @constructor.DisplayState.Open then @constructor.DisplayState.Closed else @constructor.DisplayState.Open
      @manualDisplayState if targetDisplayState is defaultDisplayState then null else targetDisplayState
    
  onClickTask: (event) ->
    taskId = $(event.target).closest('.task').data('taskId')
    
    @selectedTask _.find @tasks(), (task) => task.id() is taskId
    
    @_pageFlip()
  
  onClickBackButton: (event) ->
    @selectedTask null

    @_pageFlip()
    
  _pageFlip: ->
    @_updateNotepadPan()
    @audio.pageFlip()
    
  _updateNotepadPan: ->
    @audio.notepadPan AEc.getPanForElement @$('.notepad')[0]
