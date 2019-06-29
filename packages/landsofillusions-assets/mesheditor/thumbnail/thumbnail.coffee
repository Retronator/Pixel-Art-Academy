AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Creates an image that scales down to desired pixel size.
class LOI.Assets.MeshEditor.Thumbnail extends AM.Component
  @register 'LandsOfIllusions.Assets.MeshEditor.Thumbnail'

  onRendered: ->
    super arguments...

    @$canvas = @$('.canvas')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'

    @lightDirectionHelper = new ComputedField =>
      return unless interfaceComponent = @ancestorComponentWith('interface').interface
      interfaceComponent.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.LightDirection

    @thumbnailProvider = new ComputedField =>
      @data()
    ,
      (a, b) => a is b

    # Reactively update the image.
    @autorun (computation) =>
      thumbnailProvider = @thumbnailProvider()

      unless bounds = thumbnailProvider?.bounds()
        @canvas.width = 0
        @canvas.height = 0
        return

      @canvas.width = bounds.width
      @canvas.height = bounds.height

      @context.setTransform 1, 0, 0, 1, -bounds.x, -bounds.y

      thumbnailProvider.drawToContext @context
