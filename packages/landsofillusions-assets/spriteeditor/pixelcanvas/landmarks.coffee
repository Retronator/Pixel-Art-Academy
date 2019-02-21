LOI = LandsOfIllusions
FM = FataMorgana

class LOI.Assets.SpriteEditor.PixelCanvas.Landmarks
  if Meteor.isClient
    @_landmarkImage ?= $('<canvas>')[0]
    @_landmarkImage.width = 7
    @_landmarkImage.height = 7
  
    context = @_landmarkImage.getContext '2d'
    imageData = context.getImageData 0, 0, @_landmarkImage.width, @_landmarkImage.height
  
    bitmap = """
      0011100
      0100010
      1000001
      1000001
      1000001
      0100010
      0011100
    """
  
    for line, y in bitmap.split '\n'
      for char, x in line
        continue unless char is '1'
  
        for i in [0..3]
          imageData.data[(x + y * @_landmarkImage.width) * 4 + i] = 255
  
    context.putImageData imageData, 0, 0

  constructor: (@pixelCanvas) ->

  drawToContext: (context) ->
    return unless @pixelCanvas.landmarksEnabled()

    return unless landmarksHelper = @pixelCanvas.landmarksHelper()
    return unless landmarks = landmarksHelper()

    scale = @pixelCanvas.camera().scale()
    context.imageSmoothingEnabled = false

    # Divide landmark size by scale so it always renders at the same size.
    landmarkSize = @constructor._landmarkImage.width / scale

    # We need to draw the sphere centered on the middle of the pixel.
    offset = -landmarkSize / 2 + 0.5

    for landmark, index in landmarks
      context.drawImage @constructor._landmarkImage, landmark.x + offset, landmark.y + offset, landmarkSize, landmarkSize

      context.font = "#{7 / scale}px 'Adventure Pixel Art Academy'"
      context.fillStyle = "white"
      context.fillText landmark.number, landmark.x + offset + 8 / scale, landmark.y + offset + 6 / scale
