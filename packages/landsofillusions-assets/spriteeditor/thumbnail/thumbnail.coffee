AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Creates an image that scales down to desired pixel size.
class LOI.Assets.SpriteEditor.Thumbnail extends AM.Component
  @register 'LandsOfIllusions.Assets.SpriteEditor.Thumbnail'

  onRendered: ->
    super arguments...

    @$canvas = @$('.canvas')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'
    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: => @data()

    @lightDirectionHelper = new ComputedField =>
      return unless interfaceComponent = @ancestorComponentWith('interface').interface
      interfaceComponent.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.LightDirection

    # Reactively update the image.
    @autorun (computation) =>
      spriteData = @data()

      unless spriteData?.bounds
        @canvas.width = 0
        @canvas.height = 0
        return

      @canvas.width = spriteData.bounds.width
      @canvas.height = spriteData.bounds.height

      @context.setTransform 1, 0, 0, 1, -spriteData.bounds.x, -spriteData.bounds.y

      @sprite.drawToContext @context,
        lightDirection: @lightDirectionHelper()
