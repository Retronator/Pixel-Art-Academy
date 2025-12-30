AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.TileMap
  constructor: ->
    @map = {}
    @tiles = []
    
    @minX = Number.POSITIVE_INFINITY
    @maxX = Number.NEGATIVE_INFINITY
    @minY = Number.POSITIVE_INFINITY
    @maxY = Number.NEGATIVE_INFINITY
    
  getTile: (x, y) ->
    unless tile = @map[x]?[y]
      tile = new @constructor.Tile x, y
      @map[x] ?= {}
      @map[x][y] = tile
      @tiles.push tile
      @minX = Math.min @minX, x
      @maxX = Math.max @maxX, x
      @minY = Math.min @minY, y
      @maxY = Math.max @maxY, y
    
    tile
  
  getTileType: (x, y) ->
    return unless @map[x]?[y]
    @map[x][y].type
    
  tileFilled: (x, y) ->
    @map[x]?[y]? and @map[x][y].type isnt @constructor.Tile.Types.BlueprintEdge
    
  placeTile: (x, y, type, horizontalBlueprintNeighbors = true, verticalBlueprintNeighbors = true) ->
    tile = @getTile x, y
    
    # Don't replace structures and pathways.
    return tile if tile.type in [@constructor.Tile.Types.Building, @constructor.Tile.Types.Flag, @constructor.Tile.Types.Gate, @constructor.Tile.Types.Sidewalk, @constructor.Tile.Types.Road]
    
    # Placing a tile places that tile to the target and blueprints around it.
    tile.type = type
    
    if horizontalBlueprintNeighbors
      leftNeighbor = @getTile x - 1, y
      leftNeighbor.type ?= @constructor.Tile.Types.Blueprint
      rightNeighbor = @getTile x + 1, y
      rightNeighbor.type ?= @constructor.Tile.Types.Blueprint
    
    if verticalBlueprintNeighbors
      topNeighbor = @getTile x, y - 1
      topNeighbor.type ?= @constructor.Tile.Types.Blueprint
      bottomNeighbor = @getTile x, y + 1
      bottomNeighbor.type ?= @constructor.Tile.Types.Blueprint
      
    tile
    
  placeExpansionPoint: (x, y, direction, goalIds, connectionPointOptions) ->
    tile = @getTile x, y
    tile.type = @constructor.Tile.Types.ExpansionPoint
    tile.expansionDirection = direction
    tile.goalIds = goalIds
    tile.connectionPoint = connectionPointOptions
  
  placeRoad: (pathway, options = {}) ->
    if options.useGlobalPositions
      waypoints = [pathway.startPoint.globalPosition, pathway.globalWaypointPositions..., pathway.endPoint.globalPosition]
      
    else
      waypoints = [pathway.startPoint.localPosition, pathway.localWaypointPositions..., pathway.endPoint.localPosition]

    waypoints = _.reverse waypoints if options.accessRoad
    type = @constructor.Tile.Types.Road
    
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
        for offset in [-1, 0, 1]
          x = if vertical then start.x + offset else coordinate
          y = if vertical then coordinate else start.y + offset
          
          if offset is 0
            tile = @getTile x, y
            type = @constructor.Tile.Types.Sidewalk if options.accessRoad and tile.type is @constructor.Tile.Types.Road
            @placeTile x, y, type, vertical and not options.noBlueprint, not vertical and not options.noBlueprint

            if options.solidLines
              tile.roadMarkingStyles ?= []
              tile.roadMarkingStyles.push 'solid-lines'
            
          else unless options.noGround
            @placeTile x, y, @constructor.Tile.Types.Ground, vertical and not options.noBlueprint, not vertical and not options.noBlueprint
            
        if coordinate is startCoordinate and waypointIndex and not options.noGround
          @placeTile start.x - 1, start.y - 1, @constructor.Tile.Types.Ground
          @placeTile start.x + 1, start.y - 1, @constructor.Tile.Types.Ground
          @placeTile start.x - 1, start.y + 1, @constructor.Tile.Types.Ground
          @placeTile start.x + 1, start.y + 1, @constructor.Tile.Types.Ground
        
    # Explicit return to avoid result collection.
    return

  finishConstruction: (options = {}) ->
    # Determine road neighbors.
    for tile in @tiles when tile.type is @constructor.Tile.Types.Road
      x = tile.position.x
      y = tile.position.y
      left = @map[x - 1]?[y]?.type is @constructor.Tile.Types.Road
      right = @map[x + 1]?[y]?.type is @constructor.Tile.Types.Road
      up = @map[x]?[y - 1]?.type is @constructor.Tile.Types.Road
      down = @map[x]?[y + 1]?.type is @constructor.Tile.Types.Road
      tile.roadNeighbors = {left, right, up, down}
      tile.intersection = _.sumBy([left, right, up, down], (neighbor) => if neighbor then 1 else 0) > 2
    
    # Add road marking styles.
    for tile in @tiles when tile.type is @constructor.Tile.Types.Road
      x = tile.position.x
      y = tile.position.y
      tile.roadMarkingStyles ?= []

      if options.onlySolidRoadLines
        tile.roadMarkingStyles.push 'solid-lines' unless 'solid-lines' in tile.roadMarkingStyles
      
      else
        tile.roadMarkingStyles.push "vertical-lines-#{_.modulo tile.position.y, 3}" if (tile.roadNeighbors.up or tile.roadNeighbors.down) and not tile.roadNeighbors.left and not tile.roadNeighbors.right
  
      tile.roadMarkingStyles.push 'intersection' if tile.intersection
      tile.roadMarkingStyles.push 'intersection-left' if tile.roadNeighbors.left and @map[x - 1][y].intersection
      tile.roadMarkingStyles.push 'intersection-right' if tile.roadNeighbors.right and @map[x + 1][y].intersection
      tile.roadMarkingStyles.push 'intersection-up' if tile.roadNeighbors.up and @map[x][y - 1].intersection
      tile.roadMarkingStyles.push 'intersection-down' if tile.roadNeighbors.down and @map[x][y + 1].intersection

    # Place blueprint edges.
    return if options.noBlueprintEdges
    filledTiles = _.clone @tiles
    
    for filledTile in filledTiles
      for xOffset in [-1, 0, 1]
        # Edges are those neighbors of filled tiles that are empty.
        for yOffset in [-1, 0, 1]
          x = filledTile.position.x + xOffset
          y = filledTile.position.y + yOffset
          continue if @tileFilled x, y
      
          upLeft = @tileFilled x - 1, y - 1
          up = @tileFilled x, y - 1
          upRight = @tileFilled x + 1, y - 1
          left = @tileFilled x - 1, y
          right = @tileFilled x + 1, y
          downLeft = @tileFilled x - 1, y + 1
          down = @tileFilled x, y + 1
          downRight = @tileFilled x + 1, y + 1
          
          tile = @getTile x, y
          tile.type = @constructor.Tile.Types.BlueprintEdge
          tile.edgeDirections =
            left: upRight or right or downRight
            right: upLeft or left or downLeft
            up: downLeft or down or downRight
            down: upLeft or up or upRight
            
          # Opposite openings cancel each other.
          if tile.edgeDirections.left and tile.edgeDirections.right
            tile.edgeDirections.left = false
            tile.edgeDirections.right = false
            
          if tile.edgeDirections.up and tile.edgeDirections.down
            tile.edgeDirections.up = false
            tile.edgeDirections.down = false
            
          # If there are no edges left, we're inside of a hole and we should fill it.
          unless tile.edgeDirections.left or tile.edgeDirections.right or tile.edgeDirections.up or tile.edgeDirections.down
            tile.type = if left is @constructor.Tile.Types.Ground and right is @constructor.Tile.Types.Ground then @constructor.Tile.Types.Ground else @constructor.Tile.Types.Blueprint
            tile.edgeDirections = null

    # Explicit return to avoid result collection.
    return
