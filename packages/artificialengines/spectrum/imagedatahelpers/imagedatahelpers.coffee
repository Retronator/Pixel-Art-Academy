AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum

class AS.ImageDataHelpers
  @expandPixels: (imageData, amount) ->
    # We need a copy of the source data since changing data in-place would bleed expanded pixels themselves.
    sourceData = new Uint8ClampedArray imageData.data

    for x in [0...imageData.width]
      for y in [0...imageData.height]
        sourcePixelIndex = x + y * imageData.width

        # Skip already filled pixels.
        continue if sourceData[sourcePixelIndex * 4 + 3]

        pixelFilled = false

        for dx in [-amount..amount]
          continue unless 0 <= x + dx < imageData.width

          for dy in [-amount..amount]
            continue unless 0 <= y + dy < imageData.height

            neighborIndex = (x + dx) + (y + dy) * imageData.width
            continue unless sourceData[neighborIndex * 4 + 3]

            for offset in [0..3]
              imageData.data[sourcePixelIndex * 4 + offset] = sourceData[neighborIndex * 4 + offset]

            pixelFilled = true
            break

          break if pixelFilled

  @getImageData: (source) ->
    # Get context if we have an image.
    if source instanceof HTMLImageElement
      canvas = new AM.Canvas source.naturalWidth, source.naturalHeight
      context = canvas.getContext '2d'
      context.drawImage source, 0, 0
      source = context

    # Get context if we have a canvas.
    source = source.getContext '2d' if source.getContext?

    # Get image data if the source is a context.
    source = source.getImageData 0, 0, source.canvas.width, source.canvas.height if source.getImageData?

    # Return image data.
    return source if source instanceof ImageData

    throw new AE.ArgumentException "You must provide image data, context, canvas, or an image to get image data."
