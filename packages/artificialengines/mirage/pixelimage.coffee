AE = Artificial.Everywhere
AM = Artificial.Mirage

# Creates an image that scales down to desired pixel size.
class AM.PixelImage extends AM.Component
  @register 'Artificial.Mirage.PixelImage'

  constructor: (@options) ->
    super

    # Size of the source image in native pixels of the image.
    @sourceWidth = new ReactiveField null
    @sourceHeight = new ReactiveField null

    # Target size of the component in display (scaled) pixels.
    @targetWidth = new ReactiveField null
    @targetHeight = new ReactiveField null

  onCreated: ->
    super

    # Search for the first parent that has a display.
    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

    # Load the image
    @image = new Image
    @image.addEventListener 'load', =>
      @sourceWidth @image.width
      @sourceHeight @image.height
    ,
      false

    # Initiate the loading.
    @image.src = @options.source

  onRendered: ->
    super

    @autorun (computation) =>
      return unless sourceWidth = @sourceWidth()
      sourceHeight = @sourceHeight()

      targetWidth = @targetWidth() or sourceWidth
      targetHeight = @targetHeight() or sourceHeight

      $canvas = @$('.canvas')
      canvas = $canvas[0]
      context = canvas.getContext '2d'

      canvas.width = targetWidth
      canvas.height = targetHeight

      context.imageSmoothingEnabled = false
      context.drawImage @image, 0, 0, targetWidth, targetHeight

      displayScale = @display.scale()

      $canvas.css
        width: canvas.width * displayScale
        height: canvas.height * displayScale
