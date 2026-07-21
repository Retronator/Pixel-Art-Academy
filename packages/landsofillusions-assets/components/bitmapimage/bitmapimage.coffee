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
      if @options.bitmapId
        LOI.Assets.Bitmap.versionedDocuments.getDocumentForId @options.bitmapId()
        
      else if @options.bitmap
        @options.bitmap()
        
      else
        throw new AE.ArgumentException "Bitmap image must be provided with a way to get bitmap data."

    @bitmap = new LOI.Assets.Engine.PixelImage.Bitmap
      asset: @bitmapData
      
    if @options.loadPalette
      @autorun (computation) =>
        return unless bitmapData = @bitmapData()
        return if bitmapData.customPalette
        return unless bitmapData.palette
        
        LOI.Assets.Palette.forId.subscribeContent @, bitmapData.palette._id
        
    @bounds = new ComputedField =>
      return unless bitmapData = @bitmapData()
      if @options.autoCrop then bitmapData.getContentBounds() else bitmapData.bounds
    ,
      EJSON.equals

  onRendered: ->
    super arguments...

    @autorun =>
      canvas = @$('.canvas')[0]
      context = canvas.getContext '2d'

      # Update canvas when bitmap changes.
      bitmapData = @bitmapData()
      bounds = @bounds()

      unless bitmapData and bounds
        context.setTransform 1, 0, 0, 1, 0, 0
        context.clearRect 0, 0, canvas.width, canvas.height
        return

      scale = @options.scale or 1

      canvas.width = bounds.width * scale
      canvas.height = bounds.height * scale

      context.setTransform 1, 0, 0, 1, -bounds.x, -bounds.y
      context.clearRect 0, 0, canvas.width, canvas.height

      context.save()

      @bitmap.drawToContext context,
        lightDirection: @options.lightDirection?()
        scale: scale
        targetPalette: @options.targetPalette?()
        ditherSize: @options.ditherSize
        backgroundColor: @options.backgroundColor?()

      context.restore()

  canvasStyle: ->
    return unless bounds = @bounds()
    scale = @options.scale or 1

    width: "#{bounds.width * scale}rem"
    height: "#{bounds.height * scale}rem"
