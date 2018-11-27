LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.MappedShape extends LOI.Character.Avatar.Renderers.Renderer
  @liveEditing = true

  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    # Shape renderer prepares all sprite directions and draws the one needed by the engine.
    @frontSpriteData = new ComputedField =>
      return unless spriteId = @options.frontSpriteId()

      if @constructor.liveEditing
        LOI.Assets.Asset.forId.subscribe 'Sprite', spriteId
        LOI.Assets.Sprite.documents.findOne spriteId

      else
        LOI.Assets.Sprite.getFromCache spriteId

    @spriteData = new ComputedField =>
      spriteData = @frontSpriteData()
      
      # Landmarks source provides landmarks we try to map to (our targets).
      targetLandmarks = @options.landmarksSource?()?.landmarks()

      # Filter down to the region this shape is mapped onto.
      if @options.region
        targetLandmarks = _.filter targetLandmarks, (targetLandmark) =>
          @options.region.matchRegion targetLandmark.regionId

      @_mapSprite spriteData, targetLandmarks
      
    @frontSprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      materialsData: @options.materialsData
      flippedHorizontal: @options.flippedHorizontal

    @activeSprite = new ComputedField =>
      @frontSprite

    @_ready = new ComputedField =>
      # If we have no data, in this part, there's nothing to do.
      return true unless @options.part.options.dataLocation()

      # Shape is ready when the sprite is ready.
      @activeSprite().ready()

  ready: ->
    @_ready()
    
  landmarks: -> []

  drawToContext: (context, options = {}) ->
    return unless @_shouldDraw(options) and @ready() and @_renderingConditionsSatisfied()

    sprite = @activeSprite()

    context.save()
    sprite.drawToContext context, options
    context.restore()
