AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.StudyPlan extends PAA.PixelPad.App
  # goals: object of goals placed in the study plan
  #   {id}:
  #     markedComplete: boolean whether the player considers this goal complete
  #     connections: array of connections to required interests of other goals
  #       goalId: target goal of this connection
  #       direction: in which direction from this goal the connection is going
  #       sidewaysIndex: if the connection goes sideways, from which exit does it go
  #       interest: which of the required interests this connection ties into
  # revealed: object for storing which parts of the map have been revealed yet
  #   taskIds: an array of task IDs for which the player has seen their reveal animation
  #   goalIds: an array of goal IDs for which the player has seen their reveal animation
  # camera:
  #   origin: the position the center of the canvas displays
  #     x
  #     y
  #   scale: how big to display the elements on the canvas
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan'
  @url: -> 'studyplan'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Study Plan"
  @description: ->
    "
      An app to design your learning curriculum.
    "

  @initialize()

  @GoalConnectionDirections =
    Forward: 'Forward'
    Sideways: 'Sideways'
    
  @GoalTypes =
    ShortTerm: 'ShortTerm'
    MidTerm: 'MidTerm'
    LongTerm: 'LongTerm'
  
  @hasGoal: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId

    # Note: We return a boolean so we can use this from functions where undefined means 'not ready'.
    @state('goals')?[goalId]?
    
  @hasActiveGoal: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    return false unless goal = @state('goals')?[goalId]
    not goal.markedComplete
    
  @isGoalMarkedComplete: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    return false unless goal = @state('goals')?[goalId]
    goal.markedComplete
    
  @isTaskRevealed: (taskId) ->
    return unless revealed = @state 'revealed'
    return unless revealed.taskIds
    taskId in revealed.taskIds
    
  @isGoalRevealed: (goalId) ->
    return unless revealed = @state 'revealed'
    return unless revealed.goalIds
    goalId in revealed.goalIds
    
  @getGoalType: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    goal = PAA.Learning.Goal.getAdventureInstanceForId goalId
    currentInterests = LOI.adventure.currentInterests()
    
    # Short term goals must have an initial task that has all required interests.
    for task in goal.initialTasks()
      requiredInterests = task.requiredInterests()
      return @GoalTypes.ShortTerm if _.intersection(requiredInterests, currentInterests).length is requiredInterests.length
      
    @GoalTypes.MidTerm
    
  @canRemoveGoal: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    return false unless goal = @state('goals')?[goalId]
    not goal.connections?.length > 0
    
  @reset: ->
    @state.set {}
    
  @used: ->
    # When we've used the Study Plan, some tasks will be revealed.
    @state('revealed')?

  @getApp: ->
    return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    return unless currentApp = pixelPad.os.currentApp()
    return unless currentApp instanceof PAA.PixelPad.Apps.StudyPlan
    currentApp
    
  constructor: ->
    super arguments...

    @blueprint = new ReactiveField null
    @addGoalComponent = new ReactiveField null
    @goalSearch = new ReactiveField null
    @activeGoals = new ReactiveField null
    
  onCreated: ->
    super arguments...
    
    @addGoalOptions = new ReactiveField null
    @selectedGoalId = new ReactiveField null
    @selectedTaskId = new ReactiveField null
    
    # Instantiate all goals.
    @_goals = []
    
    @goals = new AE.LiveComputedField =>
      goal.destroy() for goal in @_goals
      @_goals = (new goalClass for goalClass in PAA.Learning.Goal.getClasses())
      @_goals
    
    @_goalNodeTemplates = {}

    @blueprint new @constructor.Blueprint @
    @addGoalComponent new @constructor.AddGoal @
    @goalSearch new @constructor.GoalSearch @
    @activeGoals new @constructor.ActiveGoals @

    # We set size in an autorun so that it adapts to window resizes.
    @autorun (computation) => @setMaximumPixelPadSize fullscreen: true

    # Maximize on run.
    @maximize()
    
  onDestroyed: ->
    super arguments...
    
    goal.destroy() for goal in @_goals
    
    goalNode.destroy() for goalId, goalNode of @_goalNodeTemplates
  
  onBackButton: ->
    return unless @modalWindowDisplayed()
    
    @closeModalWindow()
    
    # Inform that we've handled the back button.
    true
    
  createGoalNode: (goalId, goalHierarchy) ->
    unless PAA.Learning.Goal.getClassForId goalId
      console.warn "Unrecognized goal requested.", goalId
      return null
  
    unless @_goalNodeTemplates[goalId]
      @_goalNodeTemplates[goalId] = new @constructor.GoalNode
      @_goalNodeTemplates[goalId].initialize goalId
    
    @_goalNodeTemplates[goalId].cloneTemplate goalHierarchy

  hasGoal: (goalId) -> @constructor.hasGoal goalId
  
  displayAddGoal: (options) ->
    @addGoalOptions options
    @activeGoals().close()
    
  closeAddGoal: ->
    @addGoalOptions null
    
  selectGoal: (goalId) ->
    @selectedGoalId goalId
    
    # After the map bounds have recomputed, focus on the goal.
    Tracker.afterFlush => @blueprint().focusGoal goalId
    
  deselectGoal: ->
    @selectedGoalId null
    
  selectTask: (taskId) ->
    @selectedTaskId taskId
    
    task = PAA.Learning.Task.getAdventureInstanceForId taskId
    blueprint = @blueprint()
    goalComponentsById = blueprint.goalComponentsById()
    goalComponent = goalComponentsById[task.goal.id()]
    mapPosition = goalComponent.getMapPositionForTask taskId
    
    camera = blueprint.camera()
    camera.setOrigin mapPosition
    
  deselectTask: ->
    @selectedTaskId null
  
  addGoal: (options) ->
    _.defaults options, @addGoalOptions()
    
    goals = @state('goals') or {}
    goalId = options.goal.id()

    # We can't add the goal that's already in the plan. Focus it in the blueprint instead.
    if goals[goalId]
      @blueprint().focusGoal goalId
      return

    # Add the new goal.
    goals[goalId] = {}
    
    goal = PAA.Learning.Goal.getClassForId goalId
    goals[goalId].markedComplete = true if goal.allCompleted()
    
    if options.sourceGoalId
      # Add connection from the source goal.
      connection =
        goalId: goalId
        direction: options.direction
      
      connection.sidewaysIndex = options.sidewaysIndex if options.sidewaysIndex?
      
      goals[options.sourceGoalId].connections ?= []
      goals[options.sourceGoalId].connections.push connection

    # Store and close the dialog.
    @state 'goals', goals
    @closeAddGoal()

  removeGoal: (goalId) ->
    goals = @state('goals') or {}
    delete goals[goalId]
    
    for connectingGoalId, connectingGoal of goals when connectingGoal.connections
      _.remove connectingGoal.connections, (connection) => connection.goalId is goalId
    
    @state 'goals', goals
  
  modalWindowDisplayed: ->
    return unless @isCreated()
    @selectedTaskId() or @selectedGoalId() or @addGoalDisplayed()
  
  displayModalWindowCover: ->
    @addGoalDisplayed()
    
  closeModalWindow: ->
    @deselectGoal() if @selectedGoalId()
    @deselectTask() if @selectedTaskId()
    @closeAddGoal() if @addGoalDisplayed()
  
  addGoalDisplayed: ->
    @addGoalOptions()
  
  displayActiveGoals: ->
    # Show active goals once the player can mark the Pixel Art Software goal complete.
    PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.completed()
    
  events: ->
    super(arguments...).concat
      'click .modal-window-cover': @onClickModalWindowCover
  
  onClickModalWindowCover: (event) ->
    @closeModalWindow()
