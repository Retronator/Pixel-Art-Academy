AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.Goal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.Goal'
  @register @id()
  
  @titleTileHeight = 3
  @verticalPadding = 3
  
  constructor: (@blueprint, @goalId) ->
    super arguments...

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
  
  goalStyle: ->
    goalNode = @data()
    position = StudyPlan.Blueprint.TileMap.mapPosition goalNode.globalPosition
    
    left: "#{position.x}rem"
    top: "#{position.y}rem"
  
  nameStyle: ->
    goalNode = @data()
    bottomLeft = StudyPlan.Blueprint.TileMap.mapPosition goalNode.tileMap.minX - 1, goalNode.tileMap.maxY
    bottomRight = StudyPlan.Blueprint.TileMap.mapPosition goalNode.tileMap.maxX, goalNode.tileMap.maxY
    
    left: "#{bottomLeft.x}rem"
    right: "#{-bottomRight.x}rem"
    top: "#{bottomLeft.y + StudyPlan.Blueprint.TileMap.tileHeight * 2}rem"
    
  goal: ->
    goalNode = @data()
    goalNode.goal

  renderTileMapComponent: ->
    @tileMapComponent.renderComponent @currentComponent()
