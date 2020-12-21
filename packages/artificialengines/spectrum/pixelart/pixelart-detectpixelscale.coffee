AS = Artificial.Spectrum

# Calculates how much the original pixel artwork was scaled to produce the provided image.
AS.PixelArt.detectPixelScale = (imageSource, options = {}) ->
  options.maxPixelScale ?= 32
  options.compressed ?= false

  differenceThreshold = 0

  if options.compressed
    # We allow for 10% difference in color to consider it as the same cluster (25
    # out of the maximum of 255 difference) to account for possible lossy compression.
    differenceThreshold = 25

  imageData = AS.ImageDataHelpers.getImageData imageSource
  rgbaData = imageData.data
  {width, height} = imageData

  samePixelCount = 0
  samePixelCountHistogram = []

  analyzeDifference = (offset1, offset2) ->
    shadeIsDifferent = false

    # Calculate difference in each of the RGB channels.
    for i in [0..2]
      shadeDifference = Math.abs rgbaData[offset1 + i] - rgbaData[offset2 + i]

      if shadeDifference > differenceThreshold
        shadeIsDifferent = true
        break

    # If alpha differs, it's automatically a different shade.
    shadeIsDifferent = true unless rgbaData[offset1 + 3] is rgbaData[offset2 + 3]

    samePixelCount++ unless shadeIsDifferent

    # If the pixels are different, add the current pixel count to the histogram as a potential art pixel scale.
    # We limit the search to plausible pixel scales to prevent big clusters and imperfect crops (width or height not
    # being a multiple of scale) to impact our decision.
    if shadeIsDifferent
      if samePixelCount < options.maxPixelScale
        samePixelCountHistogram[samePixelCount] ?= samePixelCount: samePixelCount, occurrenceCount: 0
        samePixelCountHistogram[samePixelCount].occurrenceCount++

      # Reset the same pixel count for the next cluster.
      samePixelCount = 1

  # Perform a horizontal analysis.
  for y in [0...height]
    samePixelCount = 1

    for x in [1...width]
      pixelOffset = (y * width + x) * 4
      previousPixelOffset = pixelOffset - 4
      analyzeDifference pixelOffset, previousPixelOffset

  # Perform a vertical analysis.
  for x in [0...width]
    samePixelCount = 1

    for y in [1...height]
      pixelOffset = (y * width + x) * 4
      previousPixelOffset = pixelOffset - width * 4
      analyzeDifference pixelOffset, previousPixelOffset

  # Sort the histogram to find the same pixel count with the highest occurrence.
  samePixelCountHistogram.sort (a, b) =>
    b.occurrenceCount - a.occurrenceCount

  # Make sure we got any useful data at all.
  return unless samePixelCountHistogram[0]

  # By default, the most frequent same pixel count is considered the artwork's pixel scale.
  pixelScale = samePixelCountHistogram[0].samePixelCount

  # Further analysis depends on multiple counts so make sure they exist.
  return pixelScale unless samePixelCountHistogram[1]

  # If the top two counts have a common divisor larger than 1, the divisor should be
  # the image scale. This helps detect proper pixel scale in images with big clusters.
  greatestCommonDivisor = _.greatestCommonDivisor pixelScale, samePixelCountHistogram[1].samePixelCount
  pixelScale = greatestCommonDivisor if greatestCommonDivisor > 1

  # If an image is compressed and pixel scale is 1, we check for non-pixel art content.
  if options.compressed and pixelScale is 1
    # If the image has pixel art content, the next two pixel counts should include the actual pixel sizes.
    pixelScale = _.greatestCommonDivisor samePixelCountHistogram[1].samePixelCount, samePixelCountHistogram[2].samePixelCount

    # If the scale is still one, it probably isn't pixel art.
    return if pixelScale is 1

  # Return the calculated pixel scale.
  pixelScale
