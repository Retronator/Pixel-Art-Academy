AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.Tasks extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Tasks'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@calendar) ->
    super arguments...
  
  onCreated: ->
    super arguments...

    # Initialize Study Guide activities.
    @studyGuideSubscription = PAA.StudyGuide.Activity.initializeAll @

    @visible = new ReactiveField false

    @goals = new ComputedField =>
      return unless addedGoals = PAA.PixelBoy.Apps.StudyPlan.state()?.goals
      return unless @studyGuideSubscription.ready()

      for goalId, goalData of addedGoals
        goalClass = PAA.Learning.Goal.getClassForId goalId
        new goalClass

    @goalTasks = new ComputedField =>
      return unless goals = @goals()

      goalTasks = []

      for goal in goals
        for task in goal.tasks()
          goalTasks.push
            _id: task.id()
            task: task
            goal: goal

      goalTasks

    @activeTasks = new ComputedField =>
      return unless activeGoalTasks = _.filter @goalTasks(), (goalTask) =>
        goalTask.task.active goalTask.goal.tasks()

      activeGoalTask.task for activeGoalTask in activeGoalTasks when activeGoalTask.task.type()

    # Subscribe to character's task entries.
    PAA.Learning.Task.Entry.forCharacter.subscribe @, LOI.characterId()

  show: (callback) ->
    @visible true
    @_taskCallback = callback

  hide: ->
    @visible false
    
  visibleClass: ->
    'visible' if @visible()

  events: ->
    super(arguments...).concat
      'click .task': @onClickTask

  onClickTask: (event) ->
    task = @currentData()

    @_taskCallback
      id: task.id()

    @hide()
