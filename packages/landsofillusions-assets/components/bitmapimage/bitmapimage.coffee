AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.BitmapImage extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.BitmapImage'
  @register @id()

  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

    @bitmapData = new ComputedField =>
      return unless bitmapId = @options.bitmapId()
      LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId

    @bitmap = new LOI.Assets.Engine.PixelImage.Bitmap
      asset: @bitmapData
      
    if @options.loadPalette
      @autorun (computation) =>
        return unless bitmapData = @bitmapData()
        return if bitmapData.customPalette
        
        LOI.Assets.Palette.forId.subscribe @, bitmapData.palette._id

  onRendered: ->
    super arguments...

    @autorun =>
      canvas = @$('.canvas')[0]
      context = canvas.getContext '2d'

      # Update canvas when bitmap changes.
      bitmapData = @bitmapData()
      bounds = bitmapData?.bounds

      unless bitmapData and bounds
        context.setTransform 1, 0, 0, 1, 0, 0
        context.clearRect 0, 0, canvas.width, canvas.height
        return

      canvas.width = bounds.width
      canvas.height = bounds.height

      context.setTransform 1, 0, 0, 1, -bounds.x, -bounds.y
      context.clearRect 0, 0, canvas.width, canvas.height

      context.save()

      @bitmap.drawToContext context,
        lightDirection: @options.lightDirection?()

      context.restore()
      
  onDestroyed: ->
    super arguments...
  
    @bitmap.destroy()

  canvasStyle: ->
    return unless bounds = @bitmapData()?.bounds

    width: "#{bounds.width}rem"
    height: "#{bounds.height}rem"
