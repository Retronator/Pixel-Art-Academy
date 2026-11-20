AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelPad.Apps.StudyPlan extends PAA.PixelPad.App
  # goals: object of goals placed in the study plan
  #   {id}:
  #     archived: boolean whether the player manually archived this goal
  #     connections: array of connections to required interests of other goals
  #       goalId: target goal of this connection
  #       direction: in which direction from this goal the connection is going
  #       sidewaysIndex: if the connection goes sideways, from which exit does it go
  #       interest: which of the required interests this connection ties into
  # revealed: object for storing which parts of the map have been revealed yet
  #   taskIds: an array of task IDs for which the player has seen their reveal animation
  #   goalIds: an array of goal IDs for which the player has seen their reveal animation
  # unlockedProgressionLevel: the last progression level unlocked on the progression screen
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
  
  @ProgressionLevels = 
    Intro: 1
    ShortTermGoals: 2
    MidTermGoals: 3
    LongTermGoals: 4
  
  # This reflects the progression level the player has acknowledged on the progress screen.
  @unlockedProgressionLevel = @state.field 'unlockedProgressionLevel', default: 0

  # This reflects the progression level the player is eligible to unlock.
  @currentProgressionLevel: ->
    # TODO: Add level 4 when long-term goals are available.
    return @ProgressionLevels.MidTermGoals if @midTermGoalsAvailable()
    @ProgressionLevels.ShortTermGoals

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
    
  @getGoalData: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    @state('goals')?[goalId]
    
  @isGoalManuallyArchived: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    return false unless goal = @state('goals')?[goalId]
    goal.archived
    
  @manuallyArchiveGoal: (goalOrGoalId, value = true) ->
    goalId = _.thingId goalOrGoalId
    
    goals = @state('goals') or {}
    goals[goalId].archived = value
    @state 'goals', goals
    
  @isAnythingRevealed: ->
    return unless revealed = @state 'revealed'
    revealed.taskIds?.length or revealed.goalIds?.length
    
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
    
  @midTermGoalsAvailable: -> LM.Intro.Tutorial.Goals.Snake.completed()
    
  constructor: ->
    super arguments...

    @blueprint = new ReactiveField null
    @addGoalComponent = new ReactiveField null
    @goalSearch = new ReactiveField null
    @activeGoals = new ReactiveField null
    @interests = new ReactiveField null
    @progression = new ReactiveField null
    
    @handlingProgression = new ReactiveField true
    @showProgression = new ReactiveField false
    
  onCreated: ->
    super arguments...
    
    @addGoalOptions = new ReactiveField null
    @selectedGoalId = new ReactiveField null
    @selectedTaskId = new ReactiveField null
    @highlightedTaskId = new ReactiveField null
    
    @handlingProgression true
    @showProgression false
    
    # Instantiate all goals.
    @_goals = []
    
    @goals = new AE.LiveComputedField =>
      goal.destroy() for goal in @_goals
      @_goals = (new goalClass for goalClass in PAA.Learning.Goal.getClasses())
      @_goals
    
    # Subscribe to interests that can be displayed in the Study Plan app.
    @autorun (computation) =>
      # All current (gained) interests are shown in the interests list.
      interests = LOI.adventure.currentInterests()

      # All goals added to the plan can show their required interests (in goals) and provided (in interests).
      for goal in @goals() when goal.added()
        interests = _.union interests, goal.requiredInterests(), goal.optionalInterests(), goal.interests()

      IL.Interest.forReferenceNames.subscribe @, interests
      IL.Interest.forReferenceNames.subscribeContent @, interests

    @_goalNodeTemplates = {}

    @blueprint new @constructor.Blueprint @
    @addGoalComponent new @constructor.AddGoal @
    @goalSearch new @constructor.GoalSearch @
    @activeGoals new @constructor.ActiveGoals @
    @interests new @constructor.Interests @
    @progression new @constructor.Progression

    # We set size in an autorun so that it adapts to window resizes.
    @autorun (computation) => @setMaximumPixelPadSize fullscreen: true

    # Maximize on run.
    @maximize()
    
  onRendered: ->
    super arguments...
    
    # Show progression screen if needed.
    @autorun =>
      return unless LOI.adventure.gameStateAvailable()
      return if @blueprint().revealAnimating()

      # Keep the map paused until Start closes the entire sequence of unlocked levels.

      # If the initial progression level hasn't been unlocked, immediately show the progression screen.
      unless unlockedProgressionLevel = @constructor.unlockedProgressionLevel()
        return if @showProgression()
        @showProgression true
        
      else
        # Otherwise, show the progression screen if the player is trying to add a goal they haven't unlocked yet.
        shouldProgress = false
        
        if goalIds = @addGoalOptions()?.goalIds
          # Sideways goals can be sent as an array per index.
          goalIds = _.flatten goalIds
        
          for goalId in goalIds
            goalType = @constructor.getGoalType goalId
            
            switch goalType
              when @constructor.GoalTypes.ShortTerm then shouldProgress = true if unlockedProgressionLevel < @constructor.ProgressionLevels.ShortTermGoals
              when @constructor.GoalTypes.MidTerm then shouldProgress = true if unlockedProgressionLevel < @constructor.ProgressionLevels.MidTermGoals
              when @constructor.GoalTypes.LongTerm then shouldProgress = true if unlockedProgressionLevel < @constructor.ProgressionLevels.LongTermGoals
        
        if shouldProgress
          @showProgression true
          
        @handlingProgression shouldProgress
  
  onDestroyed: ->
    super arguments...
    
    goal.destroy() for goal in @_goals
    
    goalNode.destroy() for goalId, goalNode of @_goalNodeTemplates
  
  onBackButton: ->
    return unless @modalWindowDisplayed() and not @showProgression()
    
    @closeModalWindow()
    
    # Inform that we've handled the back button.
    true
  
  inGameMusicMode: ->
    # Turn off music when the progression intro timelapse is playing.
    return unless progression = @progression()
    LM.Interface.InGameMusicMode.Off if progression.timelapsePlaying()
    
  inGameMusicModeOffFadeOut: ->
    # Immediately fade out existing music when the progression intro timelapse starts playing.
    LM.Interface.InGameMusicModeOffFade.None
    
  finishProgression: ->
    @handlingProgression false
    @showProgression false
    
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
    @blueprint().focusTask taskId
    
  deselectTask: ->
    @selectedTaskId null
    
  highlightTask: (taskId) ->
    @highlightedTaskId taskId
  
  stopHighlightingTask: ->
    @highlightedTaskId null
  
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
    @showProgression() or @selectedTaskId() or @selectedGoalId() or @addGoalDisplayed()
  
  displayModalWindowCover: ->
    @addGoalDisplayed()
    
  closeModalWindow: ->
    @deselectGoal() if @selectedGoalId()
    @deselectTask() if @selectedTaskId()
    @closeAddGoal() if @addGoalDisplayed()
  
  addGoalDisplayed: ->
    @addGoalOptions() and not @showProgression()
  
  displayActiveGoals: ->
    # Show active goals once the player can mark the Pixel Art Software goal complete.
    PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.completed()
  
  displayInterests: ->
    # Show interests once the player has more than two.
    LOI.adventure.currentInterests().length > 2
    
  events: ->
    super(arguments...).concat
      'click .modal-window-cover': @onClickModalWindowCover
  
  onClickModalWindowCover: (event) ->
    @closeModalWindow()
