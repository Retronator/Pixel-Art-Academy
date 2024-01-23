AE = Artificial.Everywhere
AM = Artificial.Mirage

# Creates an image that scales down to desired pixel size.
class AM.PixelImage extends AM.Component
  @register 'Artificial.Mirage.PixelImage'
  
  @TargetSizeFitType:
    Contain: 'Contain'

  constructor: (@options) ->
    super arguments...
    
    @options.imageSmoothingEnabled ?= false

    if _.isFunction @options.image
      @image = @options.image

    else
      @image = new ReactiveField @options.image

    # Target size of the component in display (scaled) pixels.
    @targetWidth = @options.targetWidth or new ReactiveField null
    @targetHeight = @options.targetHeight or new ReactiveField null

  onCreated: ->
    super arguments...

    # Search for the first parent that has a display.
    unless @display = @options.display
      parentWithDisplay = @ancestorComponentWith 'display'
      @display = parentWithDisplay.display

    # Load the image
    if @options.source
      image = new Image
      image.addEventListener 'load', =>
        @image image
      ,
        false

      # Initiate the loading.
      image.src = @options.source

  onRendered: ->
    super arguments...

    @$canvas = @$('.canvas')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'

    # Reactively update the image when source or target dimensions change.
    @autorun (computation) =>
      @update()

  update: ->
    return unless @isRendered()
    return unless image = @image()
    return unless displayScale = @display.scale()
    
    return unless targetWidth = @targetWidth() or image.width
    return unless targetHeight = @targetHeight() or image.height
    
    drawWidth = targetWidth
    drawHeight = targetHeight
    
    if @options.targetSizeFit is @constructor.TargetSizeFitType.Contain
      aspectRatio = image.width / image.height
      targetAspectRatio = targetWidth / targetHeight
      
      if aspectRatio > targetAspectRatio
        # Reduce width.
        drawWidth = targetWidth
        drawHeight = targetWidth / aspectRatio
        
      else
        # Reduce height.
        drawHeight = targetHeight
        drawWidth = targetHeight * aspectRatio
      
    # Resize canvas if needed.
    unless @canvas.width is targetWidth and @canvas.height is targetHeight and @displayScale is displayScale
      @canvas.width = targetWidth
      @canvas.height = targetHeight
      @displayScale = displayScale

      @$canvas.css
        width: @canvas.width * displayScale
        height: @canvas.height * displayScale

    @context.imageSmoothingEnabled = @options.imageSmoothingEnabled
    @context.drawImage image, (targetWidth - drawWidth) / 2, (targetHeight - drawHeight) / 2, targetWidth, targetHeight
