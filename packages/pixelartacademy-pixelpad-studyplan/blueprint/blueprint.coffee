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
    @bounds = new AE.Rectangle()
    @$blueprint = new ReactiveField null
    @dragBlueprint = new ReactiveField false
    
    @_goalNameTileHeightsCache = {}

  onCreated: ->
    super arguments...
    
    @display = LOI.adventure.interface.display

    # Initialize components.
    @camera new @constructor.Camera @
    @mouse new @constructor.Mouse @

    @goalHierarchy = new AE.LiveComputedField =>
      return unless @studyPlan.ready()
      return unless goalsData = @studyPlan.state 'goals'
      
      Tracker.nonreactive => new StudyPlan.GoalHierarchy @, goalsData
    
    @previewConnection = new ReactiveField null

    @previewGoalHierarchy = new AE.LiveComputedField =>
      return unless goalHierarchy = @goalHierarchy()
      return unless previewConnection = @previewConnection()
      
      Tracker.nonreactive => goalHierarchy.getPreviewGoalHierarchy previewConnection
    
    @roadTileMapComponent = new @constructor.TileMap
    
    # Create goal components and connections.
    @_goalComponentsById = {}

    @goalComponentsById = new AE.LiveComputedField =>
      return unless @studyPlan.ready()
      return unless goalsData = @studyPlan.state 'goals'
      
      previousGoalComponents = _.values @_goalComponentsById

      newGoalIds = _.keys goalsData
      
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
        goalId = unusedGoalComponent.goal.id()

        @_goalComponentsById[goalId].destroy()

        delete @_goalComponentsById[goalId]

      @_goalComponentsById

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

    @goalComponentsById.stop()
    
    @goalHierarchy().destroy()
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

  draggingClass: ->
    'dragging' if @dragBlueprint()

  focusGoal: (goalId) ->
    return unless goalComponent = @goalComponentsById()[goalId]

    camera = @camera()
    camera.setOrigin goalComponent.position()

  events: ->
    super(arguments...).concat
      'mousedown': @onMouseDown

  onMouseDown: (event) ->
    @startDragBlueprint()
