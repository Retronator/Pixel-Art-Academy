AS = Artificial.Spectrum

AS.ImageDataHelpers.expandPixels = (imageData, amount) ->
  # We need a copy of the source data since changing data in-place would bleed expanded pixels themselves.
  sourceData = new Uint8ClampedArray imageData.data

  for pass in [0...amount]
    for x in [0...imageData.width]
      for y in [0...imageData.height]
        sourcePixelIndex = x + y * imageData.width

        # Skip already filled pixels.
        continue if sourceData[sourcePixelIndex * 4 + 3]

        pixelFilled = false

        for neighborPass in [0..1]
          for dx in [-1..1]
            continue unless 0 <= x + dx < imageData.width

            for dy in [-1..1]
              continue unless dx or dy
              continue unless 0 <= y + dy < imageData.height

              if neighborPass is 0
                # Skip diagonal neighbors.
                continue if dx and dy

              else
                # Skip direct neighbors.
                continue unless dx and dy

              neighborIndex = (x + dx) + (y + dy) * imageData.width
              continue unless sourceData[neighborIndex * 4 + 3]

              for offset in [0..3]
                imageData.data[sourcePixelIndex * 4 + offset] = sourceData[neighborIndex * 4 + offset]

              pixelFilled = true
              break
            break if pixelFilled
          break if pixelFilled
