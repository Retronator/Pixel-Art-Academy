import {ReactiveField} from "meteor/peerlibrary:reactive-field"

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
  
  @hasGoal: (goalId) ->
    goalId = _.thingId goalId

    # Note: We return a boolean so we can use this from functions where undefined means 'not ready'.
    @state('goals')?[goalId]?

  constructor: ->
    super arguments...

    @blueprint = new ReactiveField null
    @addGoalComponent = new ReactiveField null
    @goalSearch = new ReactiveField null
    
    @addGoalOptions = new ReactiveField null
    
  onCreated: ->
    super arguments...
    
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

    # We set size in an autorun so that it adapts to window resizes.
    @autorun (computation) => @setMaximumPixelPadSize fullscreen: true

    # Maximize on run.
    @maximize()
    
  onDestroyed: ->
    super arguments...
    
    goal.destroy() for goal in @_goals
    
    goalNode.destroy() for goalId, goalNode of @_goalNodeTemplates
    
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
    
  closeAddGoal: ->
    @addGoalOptions null
  
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
  
  addGoalDisplayed: ->
    @addGoalOptions()
