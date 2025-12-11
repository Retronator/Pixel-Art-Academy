AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Blueprint.TileMap extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Blueprint.TileMap'
  @register @id()
  
  @version: -> 0.1

  @tileWidth = 8
  @tileHeight = 4
  
  @mapPosition: (positionOrTileX, tileY) ->
    if _.isObject positionOrTileX
      tileX = positionOrTileX.x
      tileY = positionOrTileX.y
    
    else
      tileX = positionOrTileX
    
    x: tileX * @tileWidth + tileY * @tileHeight
    y: tileY * @tileHeight

  onCreated: ->
    super arguments...
    
    @revealed = new ReactiveField false
    @buildingActive = new ReactiveField false
    @gateOpened = new ReactiveField false
    @flagRaised = new ReactiveField false
    
    @nonBlueprintTiles = new ComputedField =>
      tileMap = @data()
      _.filter tileMap.tiles, (tile) => tile.type not in [StudyPlan.TileMap.Tile.Types.BlueprintEdge, StudyPlan.TileMap.Tile.Types.Blueprint]
    
    unless @constructor._blueprintTilesImage
      @constructor._blueprintTilesImage = new ReactiveField false
      
      blueprintTilesImage = new Image
      blueprintTilesImage.onload = => @constructor._blueprintTilesImage blueprintTilesImage
      blueprintTilesImage.src = @versionedUrl '/pixelartacademy/pixelpad/apps/studyplan/blueprint-tiles.png'
      
  onRendered: ->
    super arguments...
    
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
        if tile.type is StudyPlan.TileMap.Tile.Types.BlueprintEdge
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
          
        else unless tile.type is StudyPlan.TileMap.Tile.Types.Road
          sourceX = 16
          sourceY = 10

        position = @constructor.mapPosition tile.position
        @blueprintContext.drawImage blueprintTilesImage, sourceX, sourceY, 13, 5, position.x, position.y, 13, 5
      
      @blueprintContext.restore()
      
      @_blueprintDrawnDependecy.changed()
  
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
    tile.type
  
  tileTypeClass: ->
    _.kebabCase @tileType()
  
  tileStyle: ->
    tile = @currentData()
    
    mapPosition = @constructor.mapPosition tile.position
    
    left: "#{mapPosition.x}rem"
    top: "#{mapPosition.y}rem"
    
  revealedClass: ->
    'revealed' if @revealed()
    
  buildingActiveClass: ->
    'active' if @buildingActive()
    
  gateOpenedClass: ->
    'opened' if @gateOpened()
    
  flagRaisedClass: ->
    'raised' if @flagRaised()
  
  pathwayClasses: ->
    tile = @currentData()
    
    classes = []

    switch tile.type
      when StudyPlan.TileMap.Tile.Types.Sidewalk then classes.push 'sidewalk'
      when StudyPlan.TileMap.Tile.Types.Road
        classes.push 'road'

        for side, neighborExists of tile.roadNeighbors when neighborExists
          classes.push side
      
    classes.join ' '
  
  buildingBlueprintStyle: ->
    height = 10 + Math.floor Math.random() * 10
    height-- if height in [12, 16]
    height++ if height in [13, 17]
    
    width: "13rem"
    height: "#{height}rem"
    top: "#{5 - height}rem"
