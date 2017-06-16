LOI = LandsOfIllusions

class LOI.Character.Part.Renderers.Shape
  constructor: (@engineOptions, @rendererOptions) ->
    @materialsData = new ComputedField =>
      # Provide character's skin color.
      skin:
        ramp: @rendererOptions.skin.child('hue')()
        shade: @rendererOptions.skin.child('shade')()

    # Shape renderer subscribes to all sprite directions and draws the one needed by the engine.
    @frontSpriteData = new ComputedField =>
      return unless spriteId = @rendererOptions.frontSpriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @frontSprite = new LOI.Assets.Engine.Sprite
      spriteData: @frontSpriteData
      lightDirection: @engineOptions.lightDirection
      materialsData: @materialsData

    @activeSprite = new ComputedField =>
      @frontSprite

  drawToContext: (context) ->
    @activeSprite().drawToContext context
