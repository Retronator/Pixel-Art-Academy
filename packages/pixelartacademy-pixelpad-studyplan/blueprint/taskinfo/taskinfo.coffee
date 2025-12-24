AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.TaskInfo extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.TaskInfo'
  @register @id()
  
  @edgePadding = 5
  
  @backButtonPadding = 40
  
  @taskPadding =
    left: 15
    top: 10
    bottom: 15
    right: 30
    
  
  onCreated: ->
    super arguments...
    
    @bounds = new AE.Rectangle
    
    @blueprint = @ancestorComponentOfType StudyPlan.Blueprint
    
    @task = new ReactiveField null
    @wide = new ReactiveField false
    
    @autorun (computation) =>
      return unless taskId = @blueprint.hoveredTaskId()
      @task PAA.Learning.Task.getAdventureInstanceForId taskId
      @wide false
      
    @taskPosition = new ComputedField =>
      return unless task = @task()
      return unless goalComponentsById = @blueprint.goalComponentsById()
      return unless goalComponent = goalComponentsById[task.goal.id()]
      goalComponent.getMapPositionForTask task.id()
  
  onRendered: ->
    super arguments...

    @$taskInfo = @$('.pixelartacademy-pixelpad-apps-studyplan-blueprint-taskinfo')
    
    @_resizeObserver = new ResizeObserver =>
      scale = @blueprint.display.scale()
      @bounds.width @$taskInfo.outerWidth() / scale
      @bounds.height @$taskInfo.outerHeight() / scale
    
    @_resizeObserver.observe @$taskInfo[0]
  
  onDestroyed: ->
    super arguments...
    
    @_resizeObserver.disconnect()
  
  visibleClass: ->
    'visible' if @blueprint.hoveredTaskId()
    
  wideClass: ->
    'wide' if @wide()
    
  taskInfoStyle: ->
    return unless taskPosition = @taskPosition()
    displayCoordinates = @blueprint.camera().transformCanvasToDisplay taskPosition

    infoWidth = @bounds.width()
    infoHeight = @bounds.height()
    
    scale = @blueprint.display.scale()
    screenWidth = @blueprint.bounds.width() / scale
    screenHeight = @blueprint.bounds.height() / scale
    
    if infoHeight > screenHeight - 2 * @constructor.edgePadding
      @wide true

    minScreenX = @constructor.edgePadding
    maxScreenX = screenWidth - @constructor.edgePadding
    minScreenY = @constructor.edgePadding
    maxScreenY = screenHeight - @constructor.edgePadding
    centerX = screenWidth / 2
    centerY = screenHeight / 2
    
    spaceBelow = maxScreenY - displayCoordinates.y - @constructor.taskPadding.bottom
    spaceAbove = displayCoordinates.y - @constructor.taskPadding.top - @constructor.edgePadding
    spaceToLeft = displayCoordinates.x - @constructor.taskPadding.left - @constructor.edgePadding
    spaceToRight = maxScreenX - displayCoordinates.x - @constructor.taskPadding.right

    if spaceBelow >= infoHeight or spaceAbove >= infoHeight
      if displayCoordinates.y < centerY and spaceBelow >= infoHeight or spaceAbove < infoHeight
        top = displayCoordinates.y + @constructor.taskPadding.bottom
    
      else
        bottom = screenHeight - displayCoordinates.y + @constructor.taskPadding.top
        
      left = _.clamp displayCoordinates.x - infoWidth / 2, minScreenX, maxScreenX - infoWidth
      left = @constructor.backButtonPadding if left < @constructor.backButtonPadding and (top? and top < @constructor.backButtonPadding or screenHeight - bottom - infoHeight < @constructor.backButtonPadding)
      
    else
      if displayCoordinates.x < centerX and spaceToRight >= infoWidth or spaceToLeft < infoWidth
        left = displayCoordinates.x + @constructor.taskPadding.right
        
      else
        right = screenWidth - displayCoordinates.x + @constructor.taskPadding.left
        
      top = _.clamp displayCoordinates.y - infoHeight / 2, minScreenY, maxScreenY - infoHeight
      top = @constructor.backButtonPadding if top < @constructor.backButtonPadding and (left? and left < @constructor.backButtonPadding or screenWidth - right - infoWidth < @constructor.backButtonPadding)
    
    left: "#{left}rem" if left?
    right: "#{right}rem" if right?
    top: "#{top}rem" if top?
    bottom: "#{bottom}rem" if bottom?
    
  interestDocument: ->
    interest = @currentData()
    IL.Interest.find interest
  
  acquiredInterestClass: ->
    interest = @currentData()
    'acquired' if interest.referenceString() in LOI.adventure.currentInterests()
