AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan extends PAA.PixelBoy.App
  # goals: object of goals placed in the study plan
  #   {id}:
  #     position: where the goal should appear on the canvas
  #       x
  #       y
  #     expanded: boolean if goal's tasks are displayed
  #     connections: array of connections to required interests of other goals
  #       goalId: target goal of this connection
  #       interest: which of the required interests this connection ties into
  # camera:
  #   origin: the position the center of the canvas displays
  #     x
  #     y
  #   scale: how big to display the elements on the canvas
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan'
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

  constructor: ->
    super

    @blueprint = new ReactiveField null
    @goalSearch = new ReactiveField null
    
  onCreated: ->
    super

    @blueprint new @constructor.Blueprint @
    @goalSearch new @constructor.GoalSearch @

    # We set size in an autorun so that it adapts to window resizes.
    @autorun (computation) => @setMaximumPixelBoySize()

  hasGoal: (goalId) ->
    @state('goals')?[goalId]
    
  addGoal: (options) ->
    goals = @state('goals') or {}
    goalId = options.goal.id()

    # We can't add the goal that's already in the plan. Focus it in the blueprint instead.
    if goals[goalId]
      @blueprint().focusGoal goalId
      return

    # Calculate target element's position in blueprint.
    blueprint = @blueprint()
    elementOffset = $(options.element).offset()
    blueprintOffset = blueprint.$blueprint().offset()

    canvasCoordinate = blueprint.camera().transformWindowToCanvas
      x: elementOffset.left - blueprintOffset.left
      y: elementOffset.top - blueprintOffset.top

    goals[goalId] =
      position: canvasCoordinate
      expanded: false

    # Save state with new goal.
    @state 'goals', goals

    blueprint.mouse().updateCoordinates options.event

    blueprint.startDrag
      goalPosition: canvasCoordinate
      goalId: goalId
      requireMove: true
      
  removeGoal: (goalId) ->
    goals = @state('goals') or {}
    delete goals[goalId]
    @state 'goals', goals
