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
      return unless spriteId = @options.spriteId()

      # Try to get the data from cache first.
      spriteData = LOI.Assets.Sprite.getFromCache spriteId
      
      # See if we're directly subscribed to this sprite.
      spriteData ?= LOI.Assets.Sprite.documents.findOne spriteId

      spriteData

    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      
    if @options.loadPalette
      @autorun (computation) =>
        return unless spriteData = @spriteData()
        return if spriteData.customPalette
        
        LOI.Assets.Palette.forId.subscribe @, spriteData.palette._id

  onRendered: ->
    super

    @autorun =>
      canvas = @$('.canvas')[0]
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
      @sprite.drawToContext context, lightDirection: @options.lightDirection
      context.restore()

  canvasStyle: ->
    return unless bounds = @spriteData()?.bounds

    width: "#{bounds.width}rem"
    height: "#{bounds.height}rem"
