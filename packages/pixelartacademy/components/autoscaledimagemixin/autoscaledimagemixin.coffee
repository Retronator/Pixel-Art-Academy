AM = Artificial.Mirage
AS = Artificial.Spectrum
PAA = PixelArtAcademy

class PAA.Components.AutoScaledImageMixin extends AM.Component
  onCreated: ->
    super arguments...

    @imageInfo = new ReactiveField null

  autoScaledImageStyle: ->
    return unless imageInfo = @imageInfo()
    {pixelScale, width, height} = imageInfo

    # If this is not a pixel-art image, use smooth scaling and control max height through css.
    maxHeight = @mixinParent().callFirstWith null, 'autoScaledImageMaxHeight', =>

    unless pixelScale
      style = imageRendering: 'auto'
      style.maxHeight = "#{maxHeight}rem" if maxHeight
      return style

    # By default we want the pixel scale to match our display scale.
    return unless displayScale = @mixinParent().callFirstWith null, 'autoScaledImageDisplayScale'
    desiredPixelScale = displayScale

    # If the image is taller than max height, we want to use a smaller scale.
    sourceHeight = height / pixelScale

    if maxHeight and sourceHeight > maxHeight
      cssScale = maxHeight * displayScale / height

    else
      cssScale = desiredPixelScale / pixelScale

    # Account for padding.
    padding = @mixinParent().callFirstWith null, 'autoScaledImagePadding', =>
    padding ?= 0
    paddingFull = 2 * padding * desiredPixelScale
    cssWidth = width * cssScale + paddingFull

    width: "#{cssWidth}px"

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
