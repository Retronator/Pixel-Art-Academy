AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan
TileTypes = StudyPlan.TileMap.Tile.Types

class StudyPlan.Blueprint.TileMap extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.TileMap'
  @register @id()
  
  @version: -> 0.1

  @tileWidth = 8
  @tileHeight = 4
  @tileRevealDelay = 0.05
  
  @mapPosition: (positionOrTileX, tileY) ->
    if _.isObject positionOrTileX
      tileX = positionOrTileX.x
      tileY = positionOrTileX.y
    
    else
      tileX = positionOrTileX
    
    x: tileX * @tileWidth + tileY * @tileHeight
    y: tileY * @tileHeight

  constructor: (@options = {}) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    @blueprint = @ancestorComponentOfType StudyPlan.Blueprint

    @map = {}
    
    @nonBlueprintTiles = new ComputedField =>
      tileMap = @data()
      
      tiles = (@_getTileForData tile for tile in tileMap.tiles when tile.type not in [TileTypes.BlueprintEdge, TileTypes.Blueprint])
      _.orderBy tiles, [((tile) => tile.data.position.y), ((tile) => tile.data.position.x)], ['asc', 'desc']
    
    unless @constructor._blueprintTilesImage
      @constructor._blueprintTilesImage = new ReactiveField false
      
      blueprintTilesImage = new Image
      blueprintTilesImage.onload = => @constructor._blueprintTilesImage blueprintTilesImage
      blueprintTilesImage.src = @versionedUrl '/pixelartacademy/pixelpad/apps/studyplan/blueprint-tiles.png'
      
  onRendered: ->
    super arguments...
    
    return if @options.noBlueprint
    
    @$blueprint = @$ '.blueprint'
    @blueprintCanvas = @$blueprint[0]
    @blueprintContext = @blueprintCanvas.getContext '2d'
    @_blueprintDrawnDependecy = new Tracker.Dependency
    
    @autorun (computation) =>
      return unless tileMap = @data()
      return unless blueprintTilesImage = @constructor._blueprintTilesImage()
      
      topLeftPixel = @constructor.mapPosition tileMap.minX, tileMap.minY
      bottomRightPixel = @constructor.mapPosition tileMap.maxX + 1, tileMap.maxY + 1
      
      @blueprintCanvas.width = bottomRightPixel.x - topLeftPixel.x + 1
      @blueprintCanvas.height = bottomRightPixel.y - topLeftPixel.y + 1
      
      @blueprintContext.save()
      @blueprintContext.translate -topLeftPixel.x, -topLeftPixel.y
      
      for tile in tileMap.tiles
        if tile.type is TileTypes.BlueprintEdge
          if tile.edgeDirections.left
            sourceX = 1
          
          else if tile.edgeDirections.right
            sourceX = 31
            
          else
            sourceX = 16
            
          if tile.edgeDirections.up
            sourceY = 0
            
          else if tile.edgeDirections.down
            sourceY = 20
            
          else
            sourceY = 10
          
        else unless tile.type is TileTypes.Road
          sourceX = 16
          sourceY = 10

        position = @constructor.mapPosition tile.position
        @blueprintContext.drawImage blueprintTilesImage, sourceX, sourceY, 13, 5, position.x, position.y, 13, 5
      
      @blueprintContext.restore()
      
      @_blueprintDrawnDependecy.changed()
  
  _getTile: (x, y) ->
    unless tile = @map[x]?[y]
      tile = new @constructor.Tile x, y
      @map[x] ?= {}
      @map[x][y] = tile
      
    tile
  
  _getTileForData: (tileData) ->
    tile = @_getTile tileData.position.x, tileData.position.y
    
    return tile if EJSON.equals tileData, tile.data
    
    tile.resetWithData tileData
    tile

  revealPathway: (pathway, options = {}) ->
    if options.useGlobalPositions
      waypoints = [pathway.startPoint.globalPosition, pathway.globalWaypointPositions..., pathway.endPoint.globalPosition]
      
    else
      waypoints = [pathway.startPoint.localPosition, pathway.localWaypointPositions..., pathway.endPoint.localPosition]

    for waypointIndex in [0...waypoints.length - 1]
      start = waypoints[waypointIndex]
      end = waypoints[waypointIndex + 1]
      
      if start.x is end.x
        vertical = true
        startCoordinate = start.y
        endCoordinate = end.y
        
      else if start.y is end.y
        vertical = false
        startCoordinate = start.x
        endCoordinate = end.x
        
      else
        console.warn "Pathway has diagonal sections.", pathway, waypoints
        continue
        
      for coordinate in [startCoordinate..endCoordinate]
        for offset in [-1..1]
          x = if vertical then start.x + offset else coordinate
          y = if vertical then coordinate else start.y + offset
          @_revealTile x, y
          
        if coordinate is startCoordinate and waypointIndex
          @_revealTile start.x - 1, start.y - 1
          @_revealTile start.x + 1, start.y - 1
          @_revealTile start.x - 1, start.y + 1
          @_revealTile start.x + 1, start.y + 1
        
        # Start and end waypoints are the same, so we don't need to wait on the start ones, except the first time.
        firstTile = waypointIndex is 0 and coordinate is startCoordinate
        firstTileOfStretch = coordinate is startCoordinate
        lastTile = waypointIndex is waypoints.length - 2 and coordinate is endCoordinate
        
        unless firstTileOfStretch and not firstTile or lastTile
          await @_waitForAnimation() if options.animate
        
        return if options.stopAnimation()
        
  revealTask: (taskPoint, options) ->
    Meteor.setTimeout =>
      xS = (tile.position.x for tile in taskPoint.tiles)
      minX = _.min xS
      maxX = _.max xS
      
      for x in [minX..maxX]
        revealingTiles = _.filter taskPoint.tiles, (tile) =>
          tile.position.x is x and tile.type not in [TileTypes.Sidewalk, TileTypes.Road]
        
        revealed = false
        
        for tile in revealingTiles when @_getTile(x, tile.position.y).revealed() is false
          @_revealTile x, tile.position.y
          revealed = true
        
        await @_waitForAnimation() if revealed and options.animate
        
  _waitForAnimation: ->
    _.waitForSeconds @constructor.tileRevealDelay if @constructor.tileRevealDelay

  _revealTile: (x, y) ->
    tile = @_getTile x, y
    tile.revealed true
    
  openGate: (x, y) ->
    tile = @_getTile x, y
    tile.gateOpened true
  
  setFlag: (x, y, value) ->
    tile = @_getTile x, y
    tile.flagRaised value
    
  activateBuilding: (x, y) ->
    tile = @_getTile x, y
    tile.buildingActive true
    
  blueprintStyle: ->
    return unless tileMap = @data()
    
    return unless @isRendered()
    @_blueprintDrawnDependecy.depend()

    topLeftPixel = @constructor.mapPosition tileMap.minX, tileMap.minY
    
    left: "#{topLeftPixel.x}rem"
    top: "#{topLeftPixel.y}rem"
    width: "#{@blueprintCanvas.width}rem"
    height: "#{@blueprintCanvas.height}rem"
    
  tileType: ->
    tile = @currentData()
    tile.data.type
  
  tileTypeClass: ->
    _.kebabCase @tileType()
  
  tileStyle: ->
    tile = @currentData()
    
    mapPosition = @constructor.mapPosition tile.data.position
    
    left: "#{mapPosition.x}rem"
    top: "#{mapPosition.y}rem"
    
  revealedClass: ->
    tile = @currentData()
    'revealed' if tile.revealed()
  
  buildingClass: ->
    tile = @currentData()
    classes = [_.kebabCase tile.data.building]
    classes.push 'height-8' if @_buildingHeight() is 8
    classes.join ' '
    
  buildingActiveClass: ->
    tile = @currentData()
    'active' if tile.buildingActive()
    
  gateOpenedClass: ->
    tile = @currentData()
    'opened' if tile.gateOpened()
    
  flagRaisedClass: ->
    tile = @currentData()
    'raised' if tile.flagRaised()
  
  pathwayClasses: ->
    tile = @currentData()
    
    classes = []

    switch tile.data.type
      when TileTypes.Sidewalk then classes.push 'sidewalk'
      when TileTypes.Road
        classes.push 'road', tile.data.roadMarkingStyles...

        for side, neighborExists of tile.data.roadNeighbors when neighborExists
          classes.push side
      
    classes.join ' '
  
  buildingBlueprintStyle: ->
    height = @_buildingHeight()
    
    height: "#{height}rem"
    top: "#{5 - height}rem"
    
  _buildingHeight: ->
    tile = @currentData()
    height = @constructor.buildings.heights[tile.data.building] or 10
    height++ if height in [13, 17]
    height
  
  expansionPointDirectionClass: ->
    tile = @currentData()
    _.kebabCase tile.data.expansionDirection
    
  events: ->
    super(arguments...).concat
      'click .flag .image': @onClickFlagImage
      'click .expansion-point': @onClickExpansionPoint
  
  onClickFlagImage: (event) ->
    tile = @currentData()
    goal = @ancestorComponentOfType StudyPlan.Blueprint.Goal

    goal.markComplete not tile.flagRaised()
  
  onClickExpansionPoint: (event) ->
    tile = @currentData()
    
    goalHierarchy = @blueprint.goalHierarchy()
    
    if tile.data.connectionPoint
      goalNode = goalHierarchy.goalNodesById[tile.data.connectionPoint.goalId]
      
      if tile.data.connectionPoint.entry
        connectionPoint = goalNode.entryPoint
        
      else if tile.data.connectionPoint.exit
        connectionPoint = goalNode.exitPoint
        
      else
        connectionPoint = goalNode.sidewaysPoints[tile.data.connectionPoint.sidewaysIndex]
      
    @blueprint.studyPlan.displayAddGoal
      availableInterests: connectionPoint?.propagatedProvidedInterests or []
      sourceGoalId: goalNode?.goalId
      direction: tile.data.expansionDirection
      sidewaysIndex: tile.data.connectionPoint?.sidewaysIndex
