AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.Blueprint extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Blueprint'
  @register @id()
  
  constructor: (@studyPlan) ->
    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @grid = new ReactiveField null
    @flowchart = new ReactiveField null
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
    @flowchart new @constructor.Flowchart @

    # Resize the canvas when app size changes.
    @autorun =>
      return unless canvas = @canvas()

      # Depend on app's actual (animating) size.
      pixelBoySize = @studyPlan.os.pixelBoy.animatingSize()
      scale = @display.scale()

      # Resize the back buffer to canvas element size, if it actually changed.
      newSize =
        width: pixelBoySize.width * scale
        height: pixelBoySize.height * scale

      for key, value of newSize
        canvas[key] = value unless canvas[key] is value

      # Bounds are reported in window pixels as well.
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

      for component in [@grid(), @flowchart()]
        continue unless component

        context.save()
        component.drawToContext context
        context.restore()

    # Create goal components and connections.
    @_goalComponentsById = {}
    @goalConnections = new ReactiveField []

    @goalComponentsById = new ComputedField =>
      return unless goalsData = @studyPlan.state 'goals'
      
      previousGoalComponents = _.values @_goalComponentsById
      goalConnections = []

      for goalId, goalData of goalsData
        if goalData.connections
          for connection in goalData.connections
            goalConnections.push
              startGoalId: goalId
              endGoalId: connection.goalId
              interest: connection.interest

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

      @goalConnections goalConnections

      # Destroy all components that aren't present any more.
      for unusedGoalComponent in previousGoalComponents
        goalId = unusedGoalComponent.goal.id()

        @_goalComponentsById[goalId].goal.destroy()
        @_goalComponentsById[goalId].state.destroy()

        delete @_goalComponentsById[goalId]

      @_goalComponentsById

    # Handle connections.
    @draggedConnection = new ReactiveField null

    @connections = new ComputedField =>
      # Create a deep clone of the connections so that we can manipulate them.
      connections = _.cloneDeep @goalConnections()

      if draggedConnection = @draggedConnection()
        # See if dragged connection is one of the existing ones.
        draggedGoalConnection = _.find connections, (connection) =>
          connection.endGoalId is draggedConnection.endGoalId and connection.interest is draggedConnection.interest

        if draggedGoalConnection
          # Disconnect it so it will be moved with the mouse.
          draggedGoalConnection.endGoalId = null

        else
          # Add the dragged connection to connections.
          connections.push draggedConnection

      scale = @display.scale()

      for connection in connections
        startGoalComponent = @_goalComponentsById[connection.startGoalId]

        $providedInterests = startGoalComponent.$('.provided-interests')
        continue unless $providedInterests?.length
        providedInterestsPosition = $providedInterests.position()

        connection.start =
          x: startGoalComponent.position().x + providedInterestsPosition.left / scale
          y: startGoalComponent.position().y + (providedInterestsPosition.top + $providedInterests.outerHeight() / 2) / scale

        if connection.endGoalId
          continue unless interestDocument = IL.Interest.find connection.interest

          continue unless endGoalComponent = @_goalComponentsById[connection.endGoalId]
          $goal = endGoalComponent.$('.pixelartacademy-pixelboy-apps-studyplan-goal')
          continue unless $goal?.length
          goalOffset = $goal.offset()

          $connector = endGoalComponent.$getConnectorByRequiredInterestId interestDocument._id
          continue unless $connector?.length
          connectorOffset = $connector.offset()

          connectorPosition =
            left: connectorOffset.left - goalOffset.left
            top: connectorOffset.top - goalOffset.top

          connection.end =
            x: endGoalComponent.position().x + (connectorPosition.left + $connector.outerWidth()) / scale
            y: endGoalComponent.position().y + (connectorPosition.top + $connector.outerHeight() / 2) / scale

        else
          connection.end = @mouse().canvasCoordinate()

      # Remove any connections that we couldn't determine.
      _.filter connections, (connection) => connection.start and connection.end

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

  connectingClass: ->
    'connecting' if @draggedConnection()

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
    camera.setOrigin goalComponent.position()

  startConnection: (startGoalId) ->
    @draggedConnection {startGoalId}

  modifyConnection: (options) ->
    # Go over all the goals and find the first connection that matches the goal and interest.
    goals = @studyPlan.state 'goals'

    for goalId, goalData of goals
      continue unless goalData.connections

      for connection in goalData.connections
        if connection.goalId is options.goalId and connection.interest is options.interest
          @draggedConnection
            startGoalId: goalId
            endGoalId: options.goalId
            interest: options.interest

          return

  endConnection: (options) ->
    return unless draggedConnection = @draggedConnection()

    startGoalComponent = @_goalComponentsById[draggedConnection.startGoalId]
    connections = startGoalComponent.state('connections') or []

    # Remove the old data if this is an existing connection.
    if draggedConnection.endGoalId
      connections = _.reject connections, (connection) =>
        connection.goalId is draggedConnection.endGoalId and connection.interest is draggedConnection.interest

    # Add the new connection.
    connections.push
      goalId: options.goalId
      interest: options.interest

    # Update state with new connections.
    startGoalComponent.state 'connections', connections

    # End dragging.
    @draggedConnection null

  events: ->
    super.concat
      'mousedown': @onMouseDown
      'mouseup': @onMouseUp

  onMouseDown: (event) ->
    # Reset dragging on any start of clicks.
    @dragHasMoved false

  onMouseUp: (event) ->
    return unless draggedConnection = @draggedConnection()

    # If we were modifying an existing connection, remove it.
    if draggedConnection.endGoalId
      startGoalComponent = @_goalComponentsById[draggedConnection.startGoalId]
      connections = startGoalComponent.state 'connections'

      connections = _.reject connections, (connection) =>
        connection.goalId is draggedConnection.endGoalId and connection.interest is draggedConnection.interest

      startGoalComponent.state 'connections', connections

    # End connecting.
    @draggedConnection null
