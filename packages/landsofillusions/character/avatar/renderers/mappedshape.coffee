LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.MappedShape extends LOI.Character.Avatar.Renderers.Renderer
  @liveEditing = true

  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    @debugDelaunay = new ReactiveField null

    # Shape renderer prepares all sprite directions and draws the one needed by the engine.
    @spriteDataInfo = {}
    @spriteData = {}

    for field, side of LOI.Engine.RenderingSides.Keys
      do (side) =>
        # Sprites in flipped renderers need to come from the other side.
        flipped = @options.region?.id.indexOf('Right') >= 0
        sourceSide = if flipped then LOI.Engine.RenderingSides.mirrorSides[side] else side

        @spriteDataInfo[side] = new ComputedField =>
          spriteId = @options["#{sourceSide}SpriteId"]()

          # If we didn't find a sprite for this side, we assume we should mirror the other side.
          unless spriteId
            mirrorSide = LOI.Engine.RenderingSides.mirrorSides[sourceSide]
            spriteId = @options["#{mirrorSide}SpriteId"]()
            flipped = not flipped

          return unless spriteId

          if @constructor.liveEditing
            spriteData = LOI.Assets.Sprite.documents.findOne spriteId

          else
            spriteData = LOI.Assets.Sprite.getFromCache spriteId

          {spriteData, flipped}

        @spriteData[side] = new ComputedField =>
          @spriteDataInfo[side]()?.spriteData

    # By default we read the viewing angle from options, but we also support sending it late from the draw call.
    defaultViewingAngle = =>
      @options.viewingAngle?() or 0

    @viewingAngleGetter = new ReactiveField defaultViewingAngle, (a, b) => a is b

    @activeSide = new ComputedField => LOI.Engine.RenderingSides.getSideForAngle @viewingAngleGetter()()

    @activeSpriteFlipped = new ComputedField =>
      @spriteDataInfo[@activeSide()]()?.flipped

    @activeSpriteData = new ComputedField =>
      spriteData = @spriteData[@activeSide()]()
      
      # Landmarks source provides landmarks we try to map to (our targets).
      targetLandmarks = @options.landmarksSource?()?.landmarks()

      # Filter down to the region this shape is mapped onto.
      if @options.region
        landmarksRegion = LOI.HumanAvatar.Regions[@options.region.getLandmarksRegionId()]

        targetLandmarks = _.filter targetLandmarks, (targetLandmark) =>
          landmarksRegion.matchRegion targetLandmark.regionId

      # If we're flipped, we want to map onto flipped landmarks.
      if @activeSpriteFlipped() and spriteData.landmarks
        sourceLandmarks = for landmark in spriteData.landmarks
          _.extend {}, landmark,
            name: landmark.name.replace('Left', '_').replace('Right', 'Left').replace('_', 'Right')
            
      else
        sourceLandmarks = spriteData?.landmarks
            
      @_mapSprite spriteData, sourceLandmarks, targetLandmarks

    @activeSprite = new LOI.Assets.Engine.Sprite
      spriteData: @activeSpriteData
      materialsData: @options.materialsData
      flippedHorizontal: @activeSpriteFlipped

    @_ready = new ComputedField =>
      # If we have no data, in this part, there's nothing to do.
      if @constructor.liveEditing
        return true unless @activeSpriteData()

      else
        return true unless @options.part.options.dataLocation()

      # Shape is ready when the sprite is ready.
      @activeSprite.ready()

  ready: ->
    @_ready()
    
  landmarks: -> []

  drawToContext: (context, options = {}) ->
    return unless @_shouldDraw(options) and @ready() and @_renderingConditionsSatisfied()

    # Update viewing angle.
    @viewingAngleGetter options.viewingAngle if options.viewingAngle

    context.save()
    context.setTransform 1, 0, 0, 1, options.textureOffset, 0

    @activeSprite.drawToContext context, options

    context.restore()
