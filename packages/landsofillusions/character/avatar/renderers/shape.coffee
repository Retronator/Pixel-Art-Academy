LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Shape extends LOI.Character.Avatar.Renderers.Renderer
  @_defaultSpriteIdsByName = {}

  @_getDefaultSpriteId: (name, useDatabaseSprites) ->
    return @_defaultSpriteIdsByName[name] if @_defaultSpriteIdsByName[name]

    if useDatabaseSprites
      @_defaultSpriteIdsByName[name] = LOI.Assets.Sprite.documents.findOne({name})?._id

    else
      @_defaultSpriteIdsByName[name] = LOI.Assets.Sprite.findInCache({name})?._id

    @_defaultSpriteIdsByName[name]

  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    @spriteDataInfo = {}
    @spriteData = {}
    @sprite = {}
    @translation = {}

    for side in @options.renderingSides
      do (side) =>
        # Sprites in flipped renderers need to come from the other side.
        sourceSide = if @options.flippedHorizontal then LOI.Engine.RenderingSides.mirrorSides[side] else side

        @spriteDataInfo[side] = new ComputedField =>
          # Don't start loading until the cache is ready.
          return unless @options.useDatabaseSprites or LOI.Assets.Sprite.cacheReady()
          
          spriteId = @options["#{sourceSide}SpriteId"]()
          flipped = false
          defaultSprite = false

          # If we didn't find a sprite for this side, we assume we should mirror the other side.
          unless spriteId
            mirrorSide = LOI.Engine.RenderingSides.mirrorSides[sourceSide]
            spriteId = @options["#{mirrorSide}SpriteId"]()
            flipped = true

          # If we still don't have a sprite, see if we have a default specified.
          unless spriteId
            defaultName = @options.part.options.default

            # When rendering articles we use extra default parts to provide all possible landmarks.
            if @options.useArticleLandmarks
              defaultName ?= @options.part.options.articleLandmarksDefault

            if defaultName
              addSideToDefaultName = (side) =>
                if _.last(defaultName) is '/'
                  "#{defaultName}#{_.kebabCase side}"

                else
                  "#{defaultName} #{_.kebabCase side}"

              spriteName = addSideToDefaultName sourceSide

              flipped = false
              defaultSprite = true

              spriteId = @constructor._getDefaultSpriteId spriteName, @options.useDatabaseSprites
              
              unless spriteId
                # Try again with a sprite without a side suffix.
                spriteId = @constructor._getDefaultSpriteId defaultName, @options.useDatabaseSprites

              unless spriteId
                spriteName = addSideToDefaultName mirrorSide
                flipped = true
                spriteId = @constructor._getDefaultSpriteId spriteName, @options.useDatabaseSprites

          return unless spriteId

          if @options.useDatabaseSprites
            spriteData = LOI.Assets.Sprite.documents.findOne spriteId

          else
            spriteData = LOI.Assets.Sprite.getFromCache spriteId

          {spriteData, flipped, defaultSprite}
        ,
          true

        @spriteData[side] = new ComputedField =>
          @spriteDataInfo[side]()?.spriteData
        ,
          true

        @sprite[side] = new LOI.Assets.Engine.Sprite
          side: sourceSide
          spriteData: @spriteData[side]
          materialsData: @options.materialsData
          flippedHorizontal: new ComputedField =>
            if @spriteDataInfo[side]()?.flipped
              not @options.flippedHorizontal

            else
              @options.flippedHorizontal
          ,
            true
          createCanvas: @options.createCanvas

        @translation[side] = new ComputedField =>
          return unless spriteDataInfo = @spriteDataInfo[side]()

          source = x: 0, y: 0
          target = x: 0, y: 0

          if origin = @getOrigin()
            source = (spriteDataInfo.spriteData?.getLandmarkForName origin.landmark, spriteDataInfo.flipped) or source

            target.x = origin.x or 0
            target.y = origin.y or 0

          x: target.x - source.x
          y: target.y - source.y
        ,
          true

        @landmarks[side] = new ComputedField =>
          # Provide sprite's landmarks, but translate them to the origin.
          return unless spriteDataInfo = @spriteDataInfo[side]()

          # If there are no landmarks, there's nothing to do.
          return unless spriteDataInfo.spriteData?.landmarks

          return unless translation = @translation[side]()

          landmarks = for landmark in spriteDataInfo.spriteData.landmarks
            # Get potentially flipped landmark data.
            landmark = spriteDataInfo.spriteData.getLandmarkForName landmark.name, spriteDataInfo.flipped

            _.extend {}, landmark,
              x: landmark.x + translation.x
              y: landmark.y + translation.y

          @_applyLandmarksRegion landmarks

          landmarks
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
    ,
      true

  destroy: ->
    for side in @options.renderingSides
      @spriteDataInfo[side].stop()
      @spriteData[side].stop()
      @sprite[side].options.flippedHorizontal.stop()
      @translation[side].stop()
      @landmarks[side].stop()

    @_ready.stop()

  ready: ->
    @_ready()

  drawToContext: (context, options = {}) ->
    super arguments...
    
    return unless @_shouldDraw(options) and @ready()

    return unless spriteDataInfo = @spriteDataInfo[options.side]()

    # Don't draw default sprites (we only use them to provide landmarks).
    return if spriteDataInfo.defaultSprite

    return unless translation = @translation[options.side]()

    context.save()
    @_handleRegionTransform context, options
    
    context.translate translation.x, translation.y

    if spriteDataInfo.flipped
      context.translate 1, 0
      context.scale -1, 1

    @sprite[options.side].drawToContext context, options
    context.restore()
