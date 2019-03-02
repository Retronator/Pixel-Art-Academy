LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.MappedShape extends LOI.Character.Avatar.Renderers.Renderer
  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    @spriteDataInfo = {}
    @spriteData = {}
    @sourceLandmarks = {}
    @mappedSpriteData = {}
    @sprite = {}
    @debugDelaunay = {}

    for side in @options.renderingSides
      do (side) =>
        @debugDelaunay[side] = new ReactiveField null

        # Sprites in flipped renderers need to come from the other side.
        flipped = @options.region?.id.indexOf('Right') >= 0
        sourceSide = if flipped then LOI.Engine.RenderingSides.mirrorSides[side] else side

        @spriteDataInfo[side] = new ComputedField =>
          # Don't start loading until the cache is ready.
          return unless @options.useDatabaseSprites or LOI.Assets.Sprite.cacheReady()

          spriteId = @options["#{sourceSide}SpriteId"]()

          # If we didn't find a sprite for this side, we assume we should mirror the other side.
          unless spriteId
            mirrorSide = LOI.Engine.RenderingSides.mirrorSides[sourceSide]
            spriteId = @options["#{mirrorSide}SpriteId"]()
            flipped = not flipped

          return unless spriteId

          if @options.useDatabaseSprites
            spriteData = LOI.Assets.Sprite.documents.findOne spriteId

          else
            spriteData = LOI.Assets.Sprite.getFromCache spriteId

          {spriteData, flipped}
        ,
          true

        @spriteData[side] = new ComputedField =>
          @spriteDataInfo[side]()?.spriteData
        ,
          true

        @sourceLandmarks[side] = new ComputedField =>
          return unless spriteDataInfo = @spriteDataInfo[side]()
          return unless spriteData = spriteDataInfo.spriteData

          # If we're flipped, we want to map onto flipped landmarks.
          if spriteDataInfo.flipped and spriteData.landmarks
            for landmark in spriteData.landmarks
              _.extend {}, landmark,
                name: landmark.name.replace('Left', '_').replace('Right', 'Left').replace('_', 'Right')

          else
            spriteData.landmarks
        ,
          true
      
        @mappedSpriteData[side] = new ComputedField =>
          return unless spriteDataInfo = @spriteDataInfo[side]()
          return unless spriteData = spriteDataInfo.spriteData

          # Landmarks source provides landmarks we try to map to (our targets).
          targetLandmarks = @options.landmarksSource?()?.landmarks[side]()

          # Filter down to the region this shape is mapped onto.
          if @options.region
            landmarksRegion = LOI.HumanAvatar.Regions[@options.region.getLandmarksRegionId()]

            targetLandmarks = _.filter targetLandmarks, (targetLandmark) =>
              landmarksRegion.matchRegion targetLandmark.regionId

          sourceLandmarks = @sourceLandmarks[side]()

          @_mapSprite side, spriteData, sourceLandmarks, targetLandmarks, spriteDataInfo.flipped

        @sprite[side] = new LOI.Assets.Engine.Sprite
          spriteData: @mappedSpriteData[side]
          materialsData: @options.materialsData
          flippedHorizontal: new ComputedField =>
            @spriteDataInfo[side]()?.flipped
          ,
            true
          createCanvas: @options.createCanvas

        @landmarks[side] = => []

        @usedLandmarks[side] = new ComputedField =>
          return unless landmarks = @sourceLandmarks[side]()
          landmark.name for landmark in landmarks
        ,
          true

        @usedLandmarksCenter[side] = new ComputedField =>
          @_usedLandmarksCenter side
        ,
          true

    @_ready = new ComputedField =>
      # Wait until the cache is ready.
      return unless @options.useDatabaseSprites or LOI.Assets.Sprite.cacheReady()

      for side in @options.renderingSides
        # If we have no data in this part for this side, there's nothing to do.
        continue unless @spriteDataInfo[side]()

        # Shape is ready when the sprite is ready.
        return false unless @sprite[side].ready()

      true

  destroy: ->
    for side in @options.renderingSides
      @spriteDataInfo[side].stop()
      @spriteData[side].stop()
      @sourceLandmarks[side].stop()
      @mappedSpriteData[side].stop()
      @sprite[side].options.flippedHorizontal.stop()
      @usedLandmarks[side].stop()
      @usedLandmarksCenter[side].stop()

    @_ready.stop()

  ready: ->
    @_ready()

  drawToContext: (context, options = {}) ->
    super arguments...

    return unless @_shouldDraw(options) and @ready() and @_renderingConditionsSatisfied()

    context.save()

    if @options.centerOnUsedLandmarks
      center = @usedLandmarksCenter[options.side]()
      context.translate -center.x, -center.y

    else
      context.setTransform 1, 0, 0, 1, options.textureOffset, 0

    @sprite[options.side].drawToContext context, options

    context.restore()
