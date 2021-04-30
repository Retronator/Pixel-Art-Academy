AM = Artificial.Mummification

BSON = require 'bson'
Pako = require 'pako'

if Meteor.isServer
  TextDecoder = require('text-encoder-lite').TextDecoderLite
  TextEncoder = require('text-encoder-lite').TextEncoderLite

else
  TextDecoder = window.TextDecoder
  TextEncoder = window.TextEncoder

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

# PNG file with embedded information.
class AM.EmbeddedImageData
  @debug = false

  @embed: (baseImage, data, options = {}) ->
    _.defaults options,
      borderWidthPercentage: 0.05
      emptyImageSize: 10
      minimumSize: 200
      maximumMagnification: 8
      backgroundColor: 'gray'

    # Compress the save data of this asset.
    encoder = new TextEncoder
    binaryData = encoder.encode EJSON.stringify data
    compressedBinaryData = Pako.deflateRaw binaryData, compressionOptions

    if @debug
      compressionRatio = compressedBinaryData.length / binaryData.length
      console.log "Compressed data from #{binaryData.length} to #{compressedBinaryData.length} (#{Math.round compressionRatio * 100}%)."

    # Create an empty image if it is not provided.
    baseImage ?=
      width: options.emptyImageSize
      height: options.emptyImageSize
      empty: true

    # Add border and determine magnification level needed to store binary data.
    maxSize = Math.max baseImage.width, baseImage.height
    borderWidth = Math.ceil maxSize * options.borderWidthPercentage

    width = baseImage.width + 2 * borderWidth
    height = baseImage.height + 2 * borderWidth

    # Create a 32-bit integer header that contains the length of compressedBinaryData.
    header = new Uint8Array 4
    (new Uint32Array header.buffer)[0] = compressedBinaryData.length

    # Total required length to be stored includes the header and compressed data.
    dataLength = compressedBinaryData.length + header.length

    # We use 2 least significant bits per channel to store one byte per pixel.
    minimumPixelCount = dataLength

    magnification = 1
    magnification++ while width * height * Math.pow(magnification, 2) < minimumPixelCount

    # Make the longest size at least minimum size, but don't use more than maximum magnification.
    magnification++ while maxSize * magnification < options.minimumSize and magnification < options.maximumMagnification

    # Create the canvas and fill it with background color.
    canvas = new Artificial.Mirage.Canvas width * magnification, height * magnification

    context = canvas.context
    context.fillStyle = options.backgroundColor
    context.fillRect 0, 0, canvas.width, canvas.height

    # Draw the image base to canvas.
    unless baseImage.empty
      context.imageSmoothingEnabled = false
      borderOffset = borderWidth * magnification
      context.drawImage baseImage, borderOffset, borderOffset, baseImage.width * magnification, baseImage.height * magnification

    # Embed binary data into the border of the image, filling pixels around the edge in clockwise direction.
    imageData = canvas.getFullImageData()

    x = 0
    y = 0
    fillWidth = canvas.width - 1
    fillHeight = canvas.height - 1
    fillRemaining = fillWidth
    dx = 1
    dy = 0

    for dataIndex in [0...dataLength]
      if dataIndex < 4
        value = header[dataIndex]

      else
        value = compressedBinaryData[dataIndex - 4]

      index = (x + y * canvas.width) * 4

      for offset in [0..3]
        # Get 2 bits of the value to be stored.
        valueMask = 3 << offset * 2
        valuePart = (value & valueMask) >> offset * 2

        # Clear least significant 2 bits of the image and put the value bits in its place.
        pixelValue = (imageData.data[index + offset] & 252) + valuePart
        imageData.data[index + offset] = pixelValue

      # Progress around the border.
      x += dx
      y += dy

      fillRemaining--
      continue if fillRemaining

      if dx
        dy = dx
        dx = 0
        fillRemaining = fillHeight

      else
        if dy > 0
          dx = -1

        else
          dx = 1
          fillWidth -= 2
          fillHeight -= 2
          x++
          y++

        dy = 0
        fillRemaining = fillWidth

        # If we're down to one last column, we need to go straight down.
        unless fillRemaining
          dx = 0
          dy = 1
          fillRemaining = fillHeight

    # Return generated image data.
    imageData

  @extract: (imageData) ->
    # Read embedded information.
    embeddedData = new Uint8Array imageData.width * imageData.height * 4
    header = new Uint32Array embeddedData.buffer, 0, 1

    x = 0
    y = 0
    retrieveWidth = imageData.width - 1
    retrieveHeight = imageData.height - 1
    retrieveRemaining = retrieveWidth
    dx = 1
    dy = 0

    for dataIndex in [0...embeddedData.length]
      index = (x + y * imageData.width) * 4

      break if dataIndex > 4 and dataIndex >= header[0] + 4

      value = 0

      for offset in [0..3]
        # Get 2 bits of the value.
        value += (imageData.data[index + offset] & 3) << offset * 2

      embeddedData[dataIndex] = value

      # Progress around the border.
      x += dx
      y += dy

      retrieveRemaining--
      continue if retrieveRemaining

      if dx
        dy = dx
        dx = 0
        retrieveRemaining = retrieveHeight

      else
        if dy > 0
          dx = -1

        else
          dx = 1
          retrieveWidth -= 2
          retrieveHeight -= 2
          x++
          y++

        dy = 0
        retrieveRemaining = retrieveWidth

        # If we're down to one last column, we need to go straight down.
        unless retrieveRemaining
          dx = 0
          dy = 1
          retrieveRemaining = retrieveHeight

    compressedBinaryDataLength = header[0]
    compressedBinaryData = new Uint8Array embeddedData.buffer, 4, compressedBinaryDataLength

    binaryData = Pako.inflateRaw compressedBinaryData

    try
      # First try the new encoded EJSON format.
      decoder = new TextDecoder
      data = EJSON.parse decoder.decode binaryData

    catch
      # If parsing failed, see if we have the old BSON format.
      data = BSON.deserialize binaryData

    data
