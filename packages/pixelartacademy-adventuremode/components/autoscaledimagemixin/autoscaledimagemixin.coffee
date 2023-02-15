AM = Artificial.Mirage
AS = Artificial.Spectrum
PAA = PixelArtAcademy

class PAA.Components.AutoScaledImageMixin extends AM.Component
  constructor: ->
    super arguments...

    @imageInfo = new ReactiveField null

  autoScaledImageStyle: ->
    return unless imageInfo = @imageInfo()
    {pixelScale, width, height} = imageInfo
    style = {}

    maxHeight = @mixinParent().callFirstWith null, 'autoScaledImageMaxHeight'
    maxWidth = @mixinParent().callFirstWith null, 'autoScaledImageMaxWidth'

    style.maxHeight = "#{maxHeight}rem" if maxHeight
    style.maxWidth = "#{maxWidth}rem" if maxWidth

    # If this is not a pixel art image, we want smoothing on the image.
    unless pixelScale
      style.imageRendering = 'auto'
      return style

    # By default we want the pixel scale to match our display scale.
    return unless displayScale = @mixinParent().callFirstWith null, 'autoScaledImageDisplayScale'
    desiredPixelScale = displayScale

    # If the image is bigger than max size, we want to use a smaller scale.
    sourceHeight = height / pixelScale
    sourceWidth = width / pixelScale

    if maxHeight and sourceHeight > maxHeight
      cssScale = maxHeight * displayScale / height

    if maxWidth and sourceWidth > maxWidth
      newCssScale = maxWidth * displayScale / width

      cssScale = Math.min newCssScale, cssScale or newCssScale

    # If we haven't set the scale yet, we can use the desired scale.
    cssScale ?= desiredPixelScale / pixelScale

    # Account for padding.
    padding = @mixinParent().callFirstWith null, 'autoScaledImagePadding'
    padding ?= 0
    paddingFull = 2 * padding * desiredPixelScale
    cssWidth = width * cssScale + paddingFull

    style.width = "#{cssWidth}px"
    style

  events: ->
    super(arguments...).concat
      'load .autoscaledimage': @onLoadImage

  onLoadImage: (event) ->
    image = event.target

    # Detect pixel scale and resize image appropriately.
    detectPixelScaleOptions = {}

    # Mark jpegs as compressed.
    if image.src.match /\.jpe?g$/
      detectPixelScaleOptions.compressed = true

    pixelScale = AS.PixelArt.detectPixelScale image, detectPixelScaleOptions

    @imageInfo
      pixelScale: pixelScale
      width: image.naturalWidth
      height: image.naturalHeight
