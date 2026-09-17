AS = Artificial.Spectrum

# Calculates how much the original pixel artwork was scaled to produce the provided image.
AS.PixelArt.detectPixelScale = (imageSource, options = {}) ->
  options.maxPixelScale ?= 32
  options.compressed ?= false

  differenceThreshold = 0

  if options.compressed
    # We allow for 20% difference in color to consider it as the same cluster (50
    # out of the maximum of 255 difference) to account for possible lossy compression.
    differenceThreshold = 50

  imageData = AS.ImageDataHelpers.getImageData imageSource
  rgbaData = imageData.data
  {width, height} = imageData
  return unless width and height

  samePixelCount = 0
  samePixelCountHistogramHorizontal = []
  samePixelCountHistogramVertical = []

  analyzeDifference = (offset1, offset2, histogram) ->
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
        histogram[samePixelCount] ?= {samePixelCount, occurrenceCount: 0}
        histogram[samePixelCount].occurrenceCount++

      # Reset the same pixel count for the next cluster.
      samePixelCount = 1

  performAnalysis = ->
    samePixelCount = 0
    samePixelCountHistogramHorizontal = []
    samePixelCountHistogramVertical = []

    # Perform a horizontal analysis.
    for y in [0...height]
      samePixelCount = 1

      for x in [1...width]
        pixelOffset = (y * width + x) * 4
        previousPixelOffset = pixelOffset - 4
        analyzeDifference pixelOffset, previousPixelOffset, samePixelCountHistogramHorizontal

    # Perform a vertical analysis.
    for x in [0...width]
      samePixelCount = 1

      for y in [1...height]
        pixelOffset = (y * width + x) * 4
        previousPixelOffset = pixelOffset - width * 4
        analyzeDifference pixelOffset, previousPixelOffset, samePixelCountHistogramVertical

    # Make sure we got any useful data at all.
    return unless samePixelCountHistogramHorizontal.length and samePixelCountHistogramVertical.length

    # Sort the histograms to find the same pixel count with the highest occurrence.
    samePixelCountHistogramHorizontal.sort (a, b) => b.occurrenceCount - a.occurrenceCount
    samePixelCountHistogramVertical.sort (a, b) => b.occurrenceCount - a.occurrenceCount

  # By default, the most frequent same pixel count is considered the artwork's pixel scale.
  calculatePixelScale = (histogram) =>
    pixelScale = histogram[0].samePixelCount

    # Further analysis depends on multiple counts so make sure they exist.
    return pixelScale unless histogram[1]

    # If the top two counts have a common divisor larger than 1, the divisor should be
    # the image scale. This helps detect proper pixel scale in images with big clusters.
    greatestCommonDivisor = _.greatestCommonDivisor pixelScale, histogram[1].samePixelCount
    pixelScale = greatestCommonDivisor if greatestCommonDivisor > 1

    # The remaining heuristics need a third distinct same-pixel count. Accept the scale
    # derived from the first two counts when the histogram does not provide one.
    return pixelScale unless histogram[2]

    # If the scale is 1, look if the scale is non-integer. We try to see if
    # most common counts alternate between two neighbor integers.
    if pixelScale is 1 and Math.abs(histogram[1].samePixelCount - histogram[2].samePixelCount) is 1
      # We can only safely assume this might still be pixel art if the same pixel counts are big enough.
      if Math.min(histogram[1].samePixelCount, histogram[2].samePixelCount) >= 4
        pixelScale = (histogram[1].samePixelCount * histogram[1].occurrenceCount + histogram[2].samePixelCount * histogram[2].occurrenceCount) / (histogram[1].occurrenceCount + histogram[2].occurrenceCount)

    # If pixel scale is still 1 and this could be compressed or have non-integer scaling, we check for non-pixel art content.
    if pixelScale is 1 and differenceThreshold
      # If the image has pixel art content, the next two pixel counts should include the actual pixel sizes.
      pixelScale = _.greatestCommonDivisor histogram[1].samePixelCount, histogram[2].samePixelCount

      # If the scale is still 1 and the image was compressed, it probably isn't pixel art.
      return if pixelScale is 1 and options.compressed

    # Return the calculated pixel scale.
    pixelScale

  performAnalysis()
  return unless samePixelCountHistogramHorizontal.length and samePixelCountHistogramVertical.length

  return unless horizontal = calculatePixelScale samePixelCountHistogramHorizontal
  return unless vertical = calculatePixelScale samePixelCountHistogramVertical

  if horizontal is 1 and vertical is 1 and not options.compressed
    # Before we commit to calling this pixel art at 1x, do another analysis for potential non-integer scaling.
    differenceThreshold = 50
    performAnalysis()
    return unless samePixelCountHistogramHorizontal.length and samePixelCountHistogramVertical.length

    return unless horizontal = calculatePixelScale samePixelCountHistogramHorizontal
    return unless vertical = calculatePixelScale samePixelCountHistogramVertical

    # If we're still at 1x, another potential scale is if the second-most common agree between horizontal and vertical.
    if horizontal is 1 and vertical is 1 and samePixelCountHistogramHorizontal[1] and samePixelCountHistogramHorizontal[1].samePixelCount is samePixelCountHistogramVertical[1]?.samePixelCount
      horizontal = vertical = samePixelCountHistogramHorizontal[1].samePixelCount

  {horizontal, vertical}
