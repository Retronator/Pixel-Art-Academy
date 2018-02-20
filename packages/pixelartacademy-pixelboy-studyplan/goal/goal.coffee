AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Goal'
  @register @id()

  constructor: (goalOrOptions) ->
    if goalOrOptions instanceof PAA.Learning.Goal
      @goal = goalOrOptions

    else
      {@goal, @state, @canvas} = goalOrOptions

      @position = @state.field 'position',
        equalityFunction: EJSON.equals
        lazyUpdates: true
        
      @expanded = @state.field 'expanded',
        lazyUpdates: true
  
    @goalTasks = []
    
    for task in @goal.tasks
      @goalTasks.push
        task: task

    # TODO: Calculate positioning info.

  onCreated: ->
    super

    # Subscribe to all interests of this goal.
    @autorun (computation) =>
      for interest in _.union @goal.interests(), @goal.requiredInterests()
        IL.Interest.forSearchTerm.subscribe interest

  goalStyle: ->
    return unless @state and @canvas

    # Make sure we have position present, as it will disappear when goal is being deleted.
    return unless position = @position()

    scale = @canvas.camera().scale()

    position: 'absolute'
    left: "#{position.x * scale}rem"
    top: "#{position.y * scale}rem"

  expandedClass: ->
    'expanded' if @expanded?()

  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest

  events: ->
    super.concat
      'mousedown .pixelartacademy-pixelboy-apps-studyplan-goal': @onMouseDownGoal
      'click .name': @onClickName

  onMouseDownGoal: (event) ->
    # We only deal with drag & drop for goals inside the canvas.
    return unless @canvas
    
    # Prevent browser select/dragging behavior
    event.preventDefault()
    
    @canvas.startDrag
      goalId: @goal.id()
      goalPosition: @position()

  onClickName: (event) ->
    return unless @expanded

    @expanded not @expanded()
