AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.Goal'
  @register @id()
  
  constructor: (@blueprint, @goalId) ->
    super arguments...
    
    @nameTileHeight = new ReactiveField 1
    @nameWidth = new ReactiveField 0

  onCreated: ->
    super arguments...

    @tileMapComponent = new StudyPlan.Blueprint.TileMap

    # Subscribe to all interests of this goal.
    @autorun (computation) =>
      return unless goal = @goal()
      
      for interest in _.union goal.interests(), goal.requiredInterests(), goal.optionalInterests()
        IL.Interest.forSearchTerm.subscribe interest
  
  onRendered: ->
    super arguments...
    
    @$nameArea = @$('.name-area')
    @$name = @$('.name')
    
    @_nameAreaResizeObserver = new ResizeObserver =>
      pixelHeight = @$nameArea.outerHeight() / @blueprint.display.scale()
      tileHeight = Math.ceil pixelHeight / StudyPlan.Blueprint.TileMap.tileHeight
      
      @nameTileHeight tileHeight
      @nameWidth @$name.outerWidth()
    
    @_nameAreaResizeObserver.observe @$nameArea[0]
  
  onDestroyed: ->
    super arguments...
    
    @_nameAreaResizeObserver?.disconnect()
    
  markComplete: (value) ->
    goalNode = @data()
    goalNode.markComplete value
    position = goalNode.endTaskPoint.localPosition
    @tileMapComponent.setFlag position.x, position.y, value
  
  goalStyle: ->
    return unless position = @mapPosition()
    
    left: "#{position.x}rem"
    top: "#{position.y}rem"
    
  mapPosition: ->
    return unless goalNode = @data()
    StudyPlan.Blueprint.TileMap.mapPosition goalNode.globalPosition()
  
  markedCompleteClass: ->
    return unless goalNode = @data()
    'marked-complete' if goalNode.markedComplete()
  
  nameStyle: ->
    return unless goalNode = @data()
    bottomLeft = StudyPlan.Blueprint.TileMap.mapPosition goalNode.tileMap.minX + 2, goalNode.tileMap.maxY + 2
    bottomRight = StudyPlan.Blueprint.TileMap.mapPosition goalNode.tileMap.maxX, goalNode.tileMap.maxY + 2
    
    left: "#{bottomLeft.x}rem"
    right: "#{-bottomRight.x}rem"
    top: "#{bottomLeft.y - 5}rem"
    
  goalUIStyle: ->
    left: "calc(50% + #{@nameWidth() / 2}px + 2rem)"

  goal: ->
    return unless goalNode = @data()
    goalNode.goal

  renderTileMapComponent: ->
    @tileMapComponent.renderComponent @currentComponent()
  
  canRemove: ->
    return unless goalNode = @data()
    
    # Goal can be removed when it's a leaf in the hierarchy.
    not (goalNode.forwardGoalNodes.length or goalNode.sidewaysGoalNodes.length)
    
  events: ->
    super(arguments...).concat
      'click .remove-button': @onClickRemoveButton
      
  onClickRemoveButton: (event) ->
    @blueprint.studyPlan.removeGoal @goalId

  class @MarkedComplete extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.Goal.MarkedComplete'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Checkbox
      
    onCreated: ->
      super arguments...
      
      @goal = @ancestorComponentOfType StudyPlan.Blueprint.Goal
    
    load: ->
      goalNode = @data()
      goalNode.markedComplete()
    
    save: (value) ->
      @goal.markComplete value
