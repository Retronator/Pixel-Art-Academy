LOI = LandsOfIllusions

class LOI.Character.Part.Renderers.Shape
  constructor: (@engineOptions, @rendererOptions) ->
    # Shape renderer subscribes to all sprite directions and draws the one needed by the engine.
    @frontSpriteData = new ComputedField =>
      return unless spriteId = @rendererOptions.frontSpriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @frontSprite = new LOI.Assets.Engine.Sprite
      spriteData: @frontSpriteData
      lightDirection: @engineOptions.lightDirection

    @activeSprite = new ComputedField =>
      @frontSprite

  drawToContext: (context) ->
    @activeSprite().drawToContext context
