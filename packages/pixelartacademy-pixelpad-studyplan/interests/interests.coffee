AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Interests extends StudyPlan.BottomPanel
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Interests'
  @register @id()

  onCreated: ->
    super arguments...
    
    @currentInterests = new ComputedField =>
      interests = (IL.Interest.find interest for interest in LOI.adventure.currentInterests())
      _.pull interests, undefined
      _.sortBy interests, (interest) => _.lowerCase interest.name.translate().text
      
    @addedTaskClasses = new ComputedField =>
      return unless goals = StudyPlan.state 'goals'
      
      _.flatten (for goalId of goals
        goalClass = PAA.Learning.Goal.getClassForId goalId
        goalClass.tasks()
      )

  events: ->
    super(arguments...).concat
      'click .interest': @onClickInterest
      'pointerleave .interest': @onPointerLeaveInterest

  onClickInterest: (event) ->
    interest = @currentData()
    referenceString = interest.referenceString()
    
    possibleTaskClasses = _.filter @addedTaskClasses(), (taskClass) => referenceString in taskClass.interests() and taskClass.completed()
    return unless possibleTaskClasses.length
    
    if @_lastFocusedTask in possibleTaskClasses
      # Cycle through possible task classes.
      index = possibleTaskClasses.indexOf @_lastFocusedTask
      taskClass = possibleTaskClasses[(index + 1) % possibleTaskClasses.length]
      
    else
      taskClass = possibleTaskClasses[0]
      
    @_lastFocusedTask = taskClass
    taskId = @_lastFocusedTask.id()
    
    @studyPlan.deselectGoal()
    @studyPlan.deselectTask()
    @studyPlan.highlightTask taskId
    Tracker.afterFlush => @studyPlan.blueprint().focusTask taskId
    
  onPointerLeaveInterest: (event) ->
    @studyPlan.stopHighlightingTask()
