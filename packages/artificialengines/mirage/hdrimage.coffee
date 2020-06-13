AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum

# Creates an image that scales down to desired pixel size.
class AM.HDRImage extends AM.Component
  @register 'Artificial.Mirage.HDRImage'

  constructor: (@options) ->
    super arguments...

    @texture = new ReactiveField null

    # Exposure control.
    @exposureValue = @options.exposureValue or new ReactiveField 0

  onCreated: ->
    super arguments...

    # Load the image
    loader = new THREE.RGBELoader()
    loader.setDataType THREE.FloatType
    loader.load @options.source, (texture) =>
      @texture texture

  onRendered: ->
    super arguments...

    @$canvas = @$('.hdrimage')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'

    # Reactively update the image when exposure changes.
    @autorun (computation) =>
      @update()

  update: ->
    return unless @isRendered()
    return unless texture = @texture()

    return unless width = texture.image.width
    return unless height = texture.image.height

    # Resize canvas if needed.
    unless @canvas.width is width and @canvas.height is height
      @canvas.width = width
      @canvas.height = height

    imageData = @context.getImageData 0, 0, width, height

    exposure = 2 ** @exposureValue()

    scale = exposure * 255

    for x in [0...width]
      for y in [0...height]
        pixelOffset = x + y * width

        textureDataOffset = pixelOffset * 3
        canvasDataOffset = pixelOffset * 4

        for i in [0..2]
          imageData.data[canvasDataOffset + i] = texture.image.data[textureDataOffset + i] * scale

        imageData.data[canvasDataOffset + 3] = 255

    @context.putImageData imageData, 0, 0
