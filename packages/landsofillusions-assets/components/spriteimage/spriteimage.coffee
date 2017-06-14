AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.SpriteImage extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.SpriteImage'

  constructor: (@options) ->
    super

  onCreated: ->
    super

    @spriteData = new ComputedField =>
      spriteId = @options.spriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      lightDirection: @lightDirection

  onRendered: ->
    super

    @autorun =>
      canvas = $('.canvas')[0]
      context = canvas.getContext '2d'

      # Update canvas when sprite changes.
      spriteData = @spriteData()
      bounds = spriteData?.bounds

      unless spriteData and bounds
        context.setTransform 1, 0, 0, 1, 0, 0
        context.clearRect 0, 0, canvas.width, canvas.height
        return

      canvas.width = bounds.width
      canvas.height = bounds.height

      context.setTransform 1, 0, 0, 1, -bounds.x, -bounds.y
      context.clearRect 0, 0, canvas.width, canvas.height

      context.save()
      @sprite.drawToContext context
      context.restore()

  canvasStyle: ->
    return unless bounds = @spriteData()?.bounds

    width: "#{bounds.width}rem"
    height: "#{bounds.height}rem"
