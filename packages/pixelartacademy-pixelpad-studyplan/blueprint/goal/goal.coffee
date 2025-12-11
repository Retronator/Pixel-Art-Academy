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

  destroy: ->
    super arguments...

  onCreated: ->
    super arguments...

    @tileMapComponent = new StudyPlan.Blueprint.TileMap

    # Subscribe to all interests of this goal.
    @autorun (computation) =>
      goal = @goal()
      
      for interest in _.union goal.interests(), goal.requiredInterests(), goal.optionalInterests()
        IL.Interest.forSearchTerm.subscribe interest
  
  onRendered: ->
    super arguments...
    
    @$name = @$('.name')
    @_nameResizeObserver = new ResizeObserver =>
      pixelHeight = @$name.outerHeight() / @blueprint.display.scale()
      tileHeight = Math.ceil pixelHeight / StudyPlan.Blueprint.TileMap.tileHeight
      
      @nameTileHeight tileHeight
    
    @_nameResizeObserver.observe @$name[0]
  
  onDestroyed: ->
    super arguments...
    
    @_nameResizeObserver?.disconnect()
  
  goalStyle: ->
    goalNode = @data()
    position = StudyPlan.Blueprint.TileMap.mapPosition goalNode.globalPosition()
    
    left: "#{position.x}rem"
    top: "#{position.y}rem"
  
  nameStyle: ->
    goalNode = @data()
    bottomLeft = StudyPlan.Blueprint.TileMap.mapPosition goalNode.tileMap.minX + 2, goalNode.tileMap.maxY + 2
    bottomRight = StudyPlan.Blueprint.TileMap.mapPosition goalNode.tileMap.maxX, goalNode.tileMap.maxY + 2
    
    left: "#{bottomLeft.x}rem"
    right: "#{-bottomRight.x}rem"
    top: "#{bottomLeft.y}rem"
    
  goal: ->
    goalNode = @data()
    goalNode.goal

  renderTileMapComponent: ->
    @tileMapComponent.renderComponent @currentComponent()
