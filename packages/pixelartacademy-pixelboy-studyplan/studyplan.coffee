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

    @setDefaultPixelBoySize()
    @canvas = new ReactiveField null
    
  onCreated: ->
    super
    
    @canvas new @constructor.Canvas @
    
  addGoal: (options) ->
    console.log "adding goal", options

    goals = {} #@state('goals') or {}
    goalId = options.goal.id()

    # We can't add the goal that's already in the plan.
    return if goals[goalId]

    # Calculate target element's position in canvas.
    canvas = @canvas()
    elementOffset = $(options.element).offset()
    canvasOffset = canvas.$canvas().offset()

    canvasCoordinate = canvas.camera().transformWindowToCanvas
      x: elementOffset.left - canvasOffset.left
      y: elementOffset.top - canvasOffset.top

    goals[goalId] =
      position: canvasCoordinate
      expanded: false

    console.log "new goals", goals

    # Save state with new goal.
    @state 'goals', goals
