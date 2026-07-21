AS = Artificial.Spectrum

AS.ImageDataHelpers.splitComponents = (imageData, diagonalNeighbors = true) ->
  return [] unless imageData?.data?.length

  {width, height, data} = imageData
  pixelCount = width * height
  visitedPixels = new Uint8Array pixelCount
  componentImageDatas = []
  neighborOffsets = [
    [-1, 0]
    [1, 0]
    [0, -1]
    [0, 1]
  ]

  if diagonalNeighbors
    neighborOffsets.push [-1, -1]
    neighborOffsets.push [1, -1]
    neighborOffsets.push [-1, 1]
    neighborOffsets.push [1, 1]

  isPixelFilled = (pixelIndex) ->
    data[pixelIndex * 4 + 3] > 0

  createComponentImageData = (componentPixelIndices) ->
    componentData = new Uint8ClampedArray data.length

    for componentPixelIndex in componentPixelIndices
      dataIndex = componentPixelIndex * 4

      for offset in [0..3]
        componentData[dataIndex + offset] = data[dataIndex + offset]
  
    new ImageData componentData, width, height

  for pixelIndex in [0...pixelCount]
    continue if visitedPixels[pixelIndex] or not isPixelFilled pixelIndex

    queue = [pixelIndex]
    queueIndex = 0
    componentPixelIndices = []
    visitedPixels[pixelIndex] = true

    while queueIndex < queue.length
      currentPixelIndex = queue[queueIndex]
      queueIndex++
      componentPixelIndices.push currentPixelIndex

      currentX = currentPixelIndex % width
      currentY = Math.floor currentPixelIndex / width

      for [neighborXOffset, neighborYOffset] in neighborOffsets
        neighborX = currentX + neighborXOffset
        neighborY = currentY + neighborYOffset
        continue unless 0 <= neighborX < width
        continue unless 0 <= neighborY < height

        neighborPixelIndex = neighborX + neighborY * width
        continue if visitedPixels[neighborPixelIndex]

        visitedPixels[neighborPixelIndex] = true
        continue unless isPixelFilled neighborPixelIndex

        queue.push neighborPixelIndex

    componentImageDatas.push createComponentImageData componentPixelIndices

  componentImageDatas
