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
      return unless bounds = bitmapData.bounds
      return bounds unless @options.autoCrop
      
      # Further crop into the image based on transparent pixels.
      bounds = _.clone bounds
      
      while bounds.left <= bounds.right
        pixelFound = false
        for y in [bounds.top..bounds.bottom]
          if bitmapData.findPixelAtAbsoluteCoordinates bounds.left, y
            pixelFound = true
            break
        break if pixelFound
        bounds.left++
        
      return if bounds.left > bounds.right
      
      while bounds.right >= bounds.left
        pixelFound = false
        for y in [bounds.top..bounds.bottom]
          if bitmapData.findPixelAtAbsoluteCoordinates bounds.right, y
            pixelFound = true
            break
        break if pixelFound
        bounds.right--
      
      while bounds.top <= bounds.bottom
        pixelFound = false
        for x in [bounds.left..bounds.right]
          if bitmapData.findPixelAtAbsoluteCoordinates x, bounds.top
            pixelFound = true
            break
        break if pixelFound
        bounds.top++
      
      return if bounds.top > bounds.bottom
      
      while bounds.bottom >= bounds.top
        pixelFound = false
        for x in [bounds.left..bounds.right]
          if bitmapData.findPixelAtAbsoluteCoordinates x, bounds.bottom
            pixelFound = true
            break
        break if pixelFound
        bounds.bottom--
      
      bounds.x = bounds.left
      bounds.y = bounds.top
      bounds.width = bounds.right - bounds.left + 1
      bounds.height = bounds.bottom - bounds.top + 1
      bounds
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

      canvas.width = bounds.width
      canvas.height = bounds.height

      context.setTransform 1, 0, 0, 1, -bounds.x, -bounds.y
      context.clearRect 0, 0, canvas.width, canvas.height

      context.save()

      @bitmap.drawToContext context,
        lightDirection: @options.lightDirection?()

      context.restore()

  canvasStyle: ->
    return unless bounds = @bounds()

    width: "#{bounds.width}rem"
    height: "#{bounds.height}rem"
