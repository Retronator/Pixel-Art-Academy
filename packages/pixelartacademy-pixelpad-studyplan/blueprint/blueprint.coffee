AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint'
  @register @id()
  
  constructor: (@studyPlan) ->
    super arguments...

    # Prepare all reactive fields.
    @camera = new ReactiveField null
    @mouse = new ReactiveField null
    @bounds = new AE.Rectangle
    @mapBoundingRectangle = new AE.Rectangle
    @$blueprint = new ReactiveField null
    @dragBlueprint = new ReactiveField false
    @hoveredTaskId = new ReactiveField null
    
    @_goalNameTileHeightsCache = {}

  onCreated: ->
    super arguments...
    
    @display = LOI.adventure.interface.display

    # Initialize components.
    @camera new @constructor.Camera @
    @mouse new @constructor.Mouse @
    
    # Update bounds of the blueprint.
    @autorun =>
      # Depend on app's actual (animating) size.
      pixelPadSize = @studyPlan.os.pixelPad.animatingSize()
      scale = @display.scale()
      
      # Resize the back buffer to canvas element size, if it actually changed.
      newSize =
        width: pixelPadSize.width * scale
        height: pixelPadSize.height * scale
      
      # Bounds are reported in window pixels as well.
      @bounds.width newSize.width
      @bounds.height newSize.height
    
    @goalsData = new AE.LiveComputedField =>
      return unless @studyPlan.ready()
      return unless goalsData = @studyPlan.state 'goals'
      
      # We only care about connections to minimize reactivity.
      minimalGoalsData = {}
      
      for goalId, goalData of goalsData
        minimalGoalsData[goalId] = _.pick goalData, ['connections']
        
      minimalGoalsData
    ,
      EJSON.equals

    @goalHierarchy = new AE.LiveComputedField =>
      return unless goalsData = @goalsData()
      
      Tracker.nonreactive => new StudyPlan.GoalHierarchy @, goalsData
    
    @previewConnection = new ReactiveField null

    @previewGoalHierarchy = new AE.LiveComputedField =>
      return unless goalHierarchy = @goalHierarchy()
      return unless previewConnection = @previewConnection()
      
      Tracker.nonreactive => goalHierarchy.getPreviewGoalHierarchy previewConnection
    
    @roadTileMapComponent = new @constructor.TileMap noBlueprint: true
    
    # Create goal components and connections.
    @_goalComponentsById = {}
    
    @goalIds = new AE.LiveComputedField =>
      return unless @studyPlan.ready()
      return unless goalsData = @studyPlan.state 'goals'
      goalIds = _.keys goalsData
      goalIds.sort()
      goalIds
    ,
      EJSON.equals

    @goalComponentsById = new AE.LiveComputedField =>
      return unless newGoalIds = @goalIds()
      previousGoalComponents = _.values @_goalComponentsById
      
      if previewConnection = @previewConnection()
        newGoalIds = _.union newGoalIds, [previewConnection.startGoalId, previewConnection.endGoalId]

      for goalId in newGoalIds
        goalComponent = @_goalComponentsById[goalId]

        if goalComponent
          _.pull previousGoalComponents, goalComponent

        else
          unless PAA.Learning.Goal.getClassForId goalId
            console.warn "Unrecognized goal present in study plan.", goalId
            continue
      
          goalComponent = new @constructor.Goal @, goalId
          @_goalComponentsById[goalId] = goalComponent

      # Destroy all components that aren't present any more.
      for unusedGoalComponent in previousGoalComponents
        goalId = unusedGoalComponent.goalId
        delete @_goalComponentsById[goalId]

      @_goalComponentsById
    
    # Support animating pathway reveal.
    @_animationRestarting = false
    @_pendingAnimationsCount = new ReactiveField 0
    @_animateTimeouts = []
    @_revealedPathways = []
    @initialRevealCompleted = new ReactiveField false
    
    @readyToAnimate = new ComputedField =>
      return unless @roadTileMapComponent.isRendered()
      
      goalComponentsById = @goalComponentsById()
      for goalId, goalComponent of goalComponentsById
        return unless goalComponent.isRendered()
        
      true
      
    # Reveal initial pathways.
    goalHierarchy = null
    
    @autorun (computation) =>
      return unless @readyToAnimate()
      return unless goalHierarchy = @displayedGoalHierarchy()
      goalHierarchy.roadTileMap()
      return if @_animationRestarting
      
      # Restart all animations. Wait for the current ones to cancel.
      @_animationRestarting = true
      Meteor.clearTimeout timeout for timeout in @_animateTimeouts
      @_animateTimeouts = []
      @_revealedPathways = []
      @_pointsWaitingToBeRevealed = []
      @$blueprint()?.removeClass 'animating'
      
      Tracker.nonreactive =>
        Tracker.autorun (computation) =>
          return if @_pendingAnimationsCount()
          computation.stop()
          @_animationRestarting = false
          
          # Wait for the tilemap to be reset.
          Tracker.afterFlush =>
            # Reveal the starting point.
            for rootGoalNode in goalHierarchy.rootGoalNodes
              @revealPoint rootGoalNode.entryPoint
          
            # Animate unrevealed tasks and goals.
            @_animateTimeouts.push Meteor.setTimeout =>
              @$blueprint().addClass 'animating'
              camera = @camera()
              
              for point in @_pointsWaitingToBeRevealed
                # Center camera slightly to the right of the point if we're not close enough.
                mapPosition = @constructor.TileMap.mapPosition point.globalPosition
                mapPosition.x += 50
                origin = camera.origin()
                camera.setOrigin mapPosition if Math.abs(mapPosition.x - origin.x) > 100 or Math.abs(mapPosition.y - origin.y) > 100
                
                await @revealPoint point, true
                
              @initialRevealCompleted true
            ,
              if @initialRevealCompleted() then 30 else 1000

    # Calculate total bounding rectangle of the map.
    @autorun (computation) =>
      mapBoundingRectangle = new AE.Rectangle
      
      if goalComponentsById = @goalComponentsById()
        for goalId, goalComponent of goalComponentsById
          mapBoundingRectangle.union goalComponent.mapBoundingRectangle
          
      @mapBoundingRectangle.copy mapBoundingRectangle

    # Handle blueprint dragging.
    @autorun (computation) =>
      return unless @dragBlueprint()

      newDisplayCoordinate = @mouse().displayCoordinate()
      cameraScale = @camera().scale()

      dragDelta =
        x: (@dragStartDisplayCoordinate.x - newDisplayCoordinate.x) / cameraScale
        y: (@dragStartDisplayCoordinate.y - newDisplayCoordinate.y) / cameraScale

      @dragStartDisplayCoordinate = newDisplayCoordinate

      @camera().offsetOrigin dragDelta

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $blueprint = @$('.pixelartacademy-pixelpad-apps-studyplan-blueprint')
    @$blueprint $blueprint

  onDestroyed: ->
    super arguments...

    @goalsData.stop()
    @goalIds.stop()
    @goalComponentsById.stop()
    
    @goalHierarchy()?.destroy()
    @goalHierarchy.stop()
    
    @previewGoalHierarchy()?.destroy()
    @previewGoalHierarchy.stop()
  
  getGoalNameTileHeight: (goalId) ->
    return 1 unless @isRendered()
    goalComponentsById = @goalComponentsById()

    if goalComponent = goalComponentsById[goalId]
      height = goalComponent.nameTileHeight()
      @_goalNameTileHeightsCache[goalId] = height
    
    @_goalNameTileHeightsCache[goalId] or 1
    
  revealPoint: (point, animate) ->
    # We need to check if we can reveal tasks.
    if (taskPoint = point.taskPoint) and point is taskPoint.entryPoint
      animationOptions = {animate, stopAnimation: => @_animationRestarting}
      
      goalComponentsById = @goalComponentsById()
      goalComponent = goalComponentsById[point.goalNode.goalId]
      
      if taskPoint.task
        # See if we need to open the gate.
        if taskPoint.task.requiredInterests() and taskPoint.task.hasRequiredInterests()
          goalComponent.tileMapComponent.openGate taskPoint.localPosition.x - 1, taskPoint.localPosition.y + 2
          
        # See if we need to activate the task.
        if taskPoint.task.active()
          goalComponent.tileMapComponent.activateBuilding taskPoint.localPosition.x, taskPoint.localPosition.y
          
        # See if we need to reveal task tiles.
        if taskPoint.task.completed()
          # If we're not animating, don't continue to unrevealed tasks.
          unless StudyPlan.isTaskRevealed(taskPoint.task.id()) or animate
            @_pointsWaitingToBeRevealed.push point
            return
            
          @_pendingAnimationsCount @_pendingAnimationsCount() + 1
          
          await goalComponent.tileMapComponent.revealTask taskPoint, animationOptions
          
          if animate
            # Mark that the task was revealed.
            revealed = StudyPlan.state('revealed') or {}
            revealed.taskIds ?= []
            revealed.taskIds.push taskPoint.task.id()
            StudyPlan.state 'revealed', revealed
          
          @_pendingAnimationsCount @_pendingAnimationsCount() - 1
          return if @_animationRestarting

        else
          # We can't continue unless the task is completed.
          return
        
      else if taskPoint.endTask
        goalId = taskPoint.goalNode.goalId
        
        # See if we need to reveal the end task tiles.
        if taskPoint.goalNode.goal.completed()
          # If we're not animating, don't continue to unrevealed goals.
          unless StudyPlan.isGoalRevealed(goalId) or animate
            @_pointsWaitingToBeRevealed.push point
            return
            
          @_pendingAnimationsCount @_pendingAnimationsCount() + 1
          
          await goalComponent.tileMapComponent.revealTask taskPoint, animationOptions
          
          if animate
            # Mark that the goal was revealed.
            revealed = StudyPlan.state('revealed') or {}
            revealed.goalIds ?= []
            revealed.goalIds.push goalId
            StudyPlan.state 'revealed', revealed
          
          @_pendingAnimationsCount @_pendingAnimationsCount() - 1
          return if @_animationRestarting
  
          # See if we need to raise a flag.
          if taskPoint.goalNode.markedComplete()
            raiseFlag = true

          # When revealing a goal that has all its tasks completed, automatically mark it as complete.
          else if animate and taskPoint.goalNode.goal.allCompleted()
            taskPoint.goalNode.markComplete true
            raiseFlag = true
            
          goalComponent.tileMapComponent.setFlag taskPoint.localPosition.x, taskPoint.localPosition.y, true if raiseFlag
        
        return unless taskPoint.goalNode.goal.completed()
        
    return if @_animationRestarting
    @_revealPathwaysFrom point, animate
    
  _revealPathwaysFrom: (origin, animate) ->
    revealPromises = [] if animate
    
    for pathway in origin.outgoingPathways when pathway not in @_revealedPathways
      @_revealedPathways.push pathway
      
      if animate
        do (pathway) =>
          revealPromises.push new Promise (resolve) =>
            @_animateTimeouts.push Meteor.setTimeout =>
              await @_revealPathway pathway, true
              resolve()
        
      else
        @_revealPathway pathway
        
    Promise.all revealPromises if animate
        
  _revealPathway: (pathway, animate) ->
    @_pendingAnimationsCount @_pendingAnimationsCount() + 1
    
    animationOptions = {animate, stopAnimation: => @_animationRestarting}
    
    if pathway.goalNode
      goalComponentsById = @goalComponentsById()
      goalComponent = goalComponentsById[pathway.goalNode.goalId]
      await goalComponent.tileMapComponent.revealPathway pathway, animationOptions
      
    else
      await @roadTileMapComponent.revealPathway pathway, _.extend {useGlobalPositions: true}, animationOptions
    
    @_pendingAnimationsCount @_pendingAnimationsCount() - 1
    return if @_animationRestarting
    
    @revealPoint pathway.endPoint, animate
  
  renderRoadTileMapComponent: ->
    @roadTileMapComponent.renderComponent @currentComponent()
    
  displayedGoalHierarchy: -> @previewGoalHierarchy() or @goalHierarchy()

  goalComponents: ->
    _.values @goalComponentsById()
  
  renderGoalComponent: ->
    goalComponent = Template.parentData()
    goalComponent.renderComponent @currentComponent()
    
  goalNodeForGoalComponent: ->
    goalComponent = @currentData()
    
    return unless goalHierarchy = @displayedGoalHierarchy()
    
    goalHierarchy.goalNodesById[goalComponent.goalId]

  originStyle: ->
    camera = @camera()
    originInWindow = camera.transformCanvasToWindow x: 0, y: 0

    transform: "translate3d(#{originInWindow.x}px, #{originInWindow.y}px, 0)"

  startDragBlueprint: ->
    # Dragging of blueprint needs to be handled in display coordinates since the canvas ones should technically stay
    # the same (the whole point is for the same canvas coordinate to stay under the mouse as we move it around).
    @dragStartDisplayCoordinate = @mouse().displayCoordinate()
    @dragBlueprint true

    # Wire end of dragging on mouse up anywhere in the window.
    $(document).on 'mouseup.pixelartacademy-pixelpad-apps-studyplan-blueprint-drag-blueprint', =>
      $(document).off '.pixelartacademy-pixelpad-apps-studyplan-blueprint-drag-blueprint'

      @dragBlueprint false

  animatingClass: ->
    'animating' if @initialRevealCompleted()
    
  draggingClass: ->
    'dragging' if @dragBlueprint()

  focusGoal: (goalId) ->
    return unless goalComponent = @goalComponentsById()[goalId]

    camera = @camera()
    camera.setOrigin goalComponent.mapPosition()

  events: ->
    super(arguments...).concat
      'mousedown': @onMouseDown
      'pointerenter .tile.building, pointerenter .tile.gate': @onPointerEnterTask
      'pointerleave .tile.building, pointerleave .tile.gate': @onPointerLeaveTask
      
  onPointerEnterTask: (event) ->
    tile = @currentData()
    @hoveredTaskId tile.data.taskId
    
  onPointerLeaveTask: (event) ->
    @hoveredTaskId null

  onMouseDown: (event) ->
    $target = $(event.target)
    return if $target.closest('.flag.tile').length
    return if $target.closest('.building.tile').length
    return if $target.closest('.gate.tile').length
    return if $target.closest('.goal-ui').length
    return if $target.closest('.expansion-point').length
    
    @startDragBlueprint()
