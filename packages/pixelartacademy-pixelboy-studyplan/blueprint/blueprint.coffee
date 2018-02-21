AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.Blueprint extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Blueprint'
  @register @id()
  
  constructor: (@studyPlan) ->
    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @grid = new ReactiveField null
    @bounds = new AE.Rectangle()
    @$blueprint = new ReactiveField null
    @canvas = new ReactiveField null
    @context = new ReactiveField null
    @dragGoalId = new ReactiveField null
    @dragRequireMove = new ReactiveField false
    @dragHasMoved = new ReactiveField false

  onCreated: ->
    super
    
    @display = LOI.adventure.interface.display

    # Initialize components.
    @camera new @constructor.Camera @
    @mouse new @constructor.Mouse @
    @grid new @constructor.Grid @

    # Resize the canvas when app size changes.
    @autorun =>
      return unless $blueprint = @$blueprint()
      return unless canvas = @canvas()

      # Depend on app's actual (animating) size.
      @studyPlan.os.pixelBoy.animatingSize()

      # Resize the back buffer to canvas element size, if it actually changed.
      newSize =
        width: $blueprint.width()
        height: $blueprint.height()

      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      @bounds.width newSize.width
      @bounds.height newSize.height

    # Redraw canvas routine.
    @autorun =>
      camera = @camera()
      context = @context()
      return unless context

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, @bounds.width(), @bounds.height()

      camera.applyTransformToCanvas()

      for component in [@grid()]
        continue unless component

        context.save()
        component.drawToContext context
        context.restore()

    # Create goal components.
    @_goalComponentsById = {}
    @goalComponentsById = new ComputedField =>
      return unless goalsData = @studyPlan.state 'goals'
      
      previousGoalComponents = _.values @_goalComponentsById

      for goalId, goalData of goalsData
        goalComponent = @_goalComponentsById[goalId]

        if goalComponent
          _.pull previousGoalComponents, goalComponent

        else
          # Create an instance of this goal.
          goalClass = PAA.Learning.Goal.getClassForId goalId
          goal = new goalClass

          goalStateAddress = @studyPlan.stateAddress.child("goals.\"#{goalId}\"")
          state = new LOI.StateObject address: goalStateAddress

          goalComponent = new PAA.PixelBoy.Apps.StudyPlan.Goal
            goal: goal
            state: state
            blueprint: @

          @_goalComponentsById[goalId] = goalComponent

      # Destroy all components that aren't present any more.
      for unusedGoalComponent in previousGoalComponents
        goalId = unusedGoalComponent.goal.id()

        @_goalComponentsById[goalId].goal.destroy()
        @_goalComponentsById[goalId].state.destroy()

        delete @_goalComponentsById[goalId]

      @_goalComponentsById

    # Handle goal dragging.
    @autorun (computation) =>
      return unless goalId = @dragGoalId()
      return unless goalComponent = @goalComponentsById()[goalId]
      
      newCanvasCoordinate = @mouse().canvasCoordinate()

      dragDelta =
        x: newCanvasCoordinate.x - @dragStartCanvasCoordinate.x
        y: newCanvasCoordinate.y - @dragStartCanvasCoordinate.y

      # Notify that we moved.
      @dragHasMoved true if dragDelta.x or dragDelta.y

      goalComponent.position
        x: @dragStartGoalPosition.x + dragDelta.x
        y: @dragStartGoalPosition.y + dragDelta.y

  onRendered: ->
    super

    # DOM has been rendered, initialize.
    $blueprint = @$('.pixelartacademy-pixelboy-apps-studyplan-blueprint')
    @$blueprint $blueprint

    canvas = @$('.canvas')[0]
    @canvas canvas
    @context canvas.getContext '2d'

    # Prevent click events from happening when dragging was active. We need to manually add this  event
    # listener so that we can set setCapture to true and make this listener be called before child click events.
    $blueprint[0].addEventListener 'click', =>
      # If drag has happened, don't process other clicks.
      event.stopImmediatePropagation() if @dragHasMoved()
    ,
      true

  onDestroyed: ->
    super

    for goalId, goalComponent of @goalComponentsById()
      goalComponent.goal.destroy()
      goalComponent.state.destroy()

  goalComponents: ->
    _.values @goalComponentsById()

  originStyle: ->
    camera = @camera()
    originInWindow = camera.transformCanvasToWindow x: 0, y: 0

    transform: "translate3d(#{originInWindow.x}px, #{originInWindow.y}px, 0)"

  startDrag: (options) ->
    @dragStartCanvasCoordinate = @mouse().canvasCoordinate()
    @dragStartGoalPosition = options.goalPosition
    @dragRequireMove options.requireMove
    @dragHasMoved false

    # Wire end of dragging on mouse up anywhere in the window.
    $(window).on 'mouseup.pixelartacademy-pixelboy-apps-studyplan-canvas', =>
      # If required to move, don't stop drag until we do so.
      return if @dragRequireMove() and not @dragHasMoved()

      # Delete goal if we're over trash.
      @studyPlan.removeGoal @dragGoalId() if @mouseOverTrash()

      @dragGoalId null
      $(window).off '.pixelartacademy-pixelboy-apps-studyplan-canvas'

    # Set goal component last since it triggers reactivity.
    @dragGoalId options.goalId

  draggingClass: ->
    'dragging' if @dragGoalId()

  dragged: ->
    @dragGoalId() and (@dragHasMoved() or @dragRequireMove())

  draggedClass: ->
    'dragged' if @dragged()

  mouseOverTrash: ->
    # Trash is only visible when dragged.
    return unless @dragged()

    $trash = @$('.trash')

    position = $trash.position()
    width = $trash.outerWidth()
    height = $trash.outerHeight()
    mouse = @mouse().windowCoordinate()

    (position.left < mouse.x < position.left + width) and (position.top < mouse.y < position.top + height)

  trashActiveClass: ->
    'active' if @mouseOverTrash()

  focusGoal: (goalId) ->
    return unless goalComponent = @goalComponentsById()[goalId]

    camera = @camera()
    camera.origin goalComponent.position()

  events: ->
    super.concat
      'mousedown': @onMouseDown

  onMouseDown: (event) ->
    # Reset dragging on any start of clicks.
    @dragHasMoved false
