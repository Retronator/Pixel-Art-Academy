AS = Artificial.Spectrum

createImageData = (width, height) ->
  width: width
  height: height
  data: new Uint8ClampedArray width * height * 4

setPixel = (imageData, x, y, color = [255, 255, 255, 255]) ->
  dataIndex = (x + y * imageData.width) * 4

  for value, offset in color
    imageData.data[dataIndex + offset] = value

getFilledPixelLocations = (imageData) ->
  filledPixelLocations = []

  for y in [0...imageData.height]
    for x in [0...imageData.width]
      dataIndex = (x + y * imageData.width) * 4
      filledPixelLocations.push "#{x},#{y}" if imageData.data[dataIndex + 3]

  filledPixelLocations

Tinytest.add 'artificialengines - spectrum - image data helpers split components preserves component pixels', (test) ->
  imageData = createImageData 4, 2
  setPixel imageData, 0, 0, [255, 0, 0, 255]
  setPixel imageData, 1, 0, [0, 255, 0, 255]
  setPixel imageData, 3, 1, [0, 0, 255, 255]

  componentImageDatas = AS.ImageDataHelpers.splitComponents imageData

  test.equal componentImageDatas.length, 2
  test.equal componentImageDatas[0].width, imageData.width
  test.equal componentImageDatas[0].height, imageData.height
  test.equal getFilledPixelLocations(componentImageDatas[0]), ['0,0', '1,0']
  test.equal getFilledPixelLocations(componentImageDatas[1]), ['3,1']

Tinytest.add 'artificialengines - spectrum - image data helpers split components respects diagonal neighbors', (test) ->
  imageData = createImageData 3, 3
  setPixel imageData, 0, 0
  setPixel imageData, 1, 1
  setPixel imageData, 2, 0

  diagonalComponentImageDatas = AS.ImageDataHelpers.splitComponents imageData
  directComponentImageDatas = AS.ImageDataHelpers.splitComponents imageData, false

  test.equal diagonalComponentImageDatas.length, 1
  test.equal directComponentImageDatas.length, 3
