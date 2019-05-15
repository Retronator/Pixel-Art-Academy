AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

BSON = require 'bson'
Pako = require 'pako'
# PNG = require 'fast-png'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION

class LOI.Assets.Editor.Actions.Export extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Export'
  @displayName: -> "Export"

  @debug = true
    
  execute: ->
    # Serialize asset to binary.
    asset = @asset()
    saveData = asset.getSaveData()

    binaryData = BSON.serialize saveData

    compressedBinaryData = Pako.deflateRaw binaryData, compressionOptions

    if @constructor.debug
      compressionRatio = compressedBinaryData.length / binaryData.length
      console.log "Compressed asset from #{binaryData.length} to #{compressedBinaryData.length} (#{Math.round compressionRatio * 100}%)."

    # Create image representation of asset.
    previewImage = @getPreviewImage asset

    # Add border and determine magnification level needed to store binary data.
    maxSize = Math.max previewImage.width, previewImage.height
    borderWidth = Math.ceil maxSize * 0.05

    width = previewImage.width + 2 * borderWidth
    height = previewImage.height + 2 * borderWidth

    # Create a 32-bit integer header that contains the length of compressedBinaryData.
    header = new Uint8Array 4
    (new Uint32Array header.buffer)[0] = compressedBinaryData.length

    # Total required length to be stored includes compressed data and a
    dataLength = compressedBinaryData.length + header.length

    # We use 2 least significant bits per channel to store one byte per pixel.
    minimumPixelCount = dataLength

    magnification = 1
    magnification++ while width * height * Math.pow(magnification, 2) < minimumPixelCount

    # Make the longest size at least 200, but don't use more than 8x magnification.
    magnification++ while maxSize * magnification < 200 and magnification < 8

    # Create required canvas and fill it with background color.
    canvas = $('<canvas>')[0]
    canvas.width = width * magnification
    canvas.height = height * magnification

    palette = LOI.palette()
    backgroundValue = (palette.ramps[0].shades[2].r + palette.ramps[0].shades[3].r) * 128

    context = canvas.getContext '2d'
    context.fillStyle = "rgb(#{backgroundValue}, #{backgroundValue}, #{backgroundValue})"
    context.fillRect 0, 0, canvas.width, canvas.height

    # Create exported image base.
    context.imageSmoothingEnabled = false
    borderOffset = borderWidth * magnification
    context.drawImage previewImage, borderOffset, borderOffset, previewImage.width * magnification, previewImage.height * magnification

    # Embed binary data into the border of the image, filling pixels around the edge in clockwise direction.
    imageData = context.getImageData 0, 0, canvas.width, canvas.height

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

    # Encode the PNG.
    pngData = PNG.encode imageData
    pngBlob = new Blob [pngData], type: "image/png"
    pngUrl = URL.createObjectURL pngBlob

    # Export image.
    $link = $('<a style="display:none">')
    $('body').append $link

    name = asset.name or asset._id
    nameStartIndex = name.lastIndexOf('/') or 0
    name = "#{name.substring nameStartIndex}.json.png"

    link = $link[0]
    link.download = name
    link.href = pngUrl
    link.click()

    $link.remove()

  getPreviewImage: -> throw new AE.NotImplementedException "Export action must provide a preview image of the asset."
