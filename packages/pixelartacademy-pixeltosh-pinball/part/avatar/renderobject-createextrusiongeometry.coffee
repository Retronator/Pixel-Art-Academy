AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

Pinball.Part.Avatar.RenderObject._createExtrusionGeometry = (texture, depth) ->
  imageData = texture.image.getFullImageData()
  
  # The texture has been magnified with hqx so we have smaller pixels.
  pixelSize = Pinball.CameraManager.orthographicPixelSize / Pinball.Part.Avatar.hqxScale
  
  corner =
    x: imageData.width / 2 * pixelSize
    y: imageData.height / 2 * pixelSize
    z: depth / 2
  
  vertexPairsMap = {}
  vertexPairs = []
  indices = []

  getVertexPair = (x, y, offsetU, offsetV) ->
    vertexPairsMap[x] ?= {}
    vertexPairsMap[x][y] ?= {}
    vertexPairsMap[x][y][offsetU] ?= {}
    
    unless vertexPairsMap[x][y][offsetU][offsetV]
      newVertexPair =
        x: x
        y: y
        topIndex: vertexPairs.length * 2
        bottomIndex: vertexPairs.length * 2 + 1
        offsetU: offsetU
        offsetV: offsetV
      
      vertexPairsMap[x][y][offsetU][offsetV] = newVertexPair
      vertexPairs.push newVertexPair
    
    vertexPairsMap[x][y][offsetU][offsetV]
  
  for x in [0...imageData.width]
    alpha = 0
    topLeft = null
    topRight = null
    
    for y in [0...imageData.height]
      pixelOffset = (x + y * imageData.width) * 4
      newAlpha = imageData.data[pixelOffset + 3]
      
      if newAlpha and not alpha
        # A new stripe starts.
        topLeft = getVertexPair x, y, 1, 1
        topRight = getVertexPair x + 1, y, -1, 1
        
        indices.push topLeft.bottomIndex, topLeft.topIndex, topRight.topIndex, topLeft.bottomIndex, topRight.topIndex, topRight.bottomIndex
      
      else if alpha and not newAlpha
        # The stripe ended.
        bottomLeft = getVertexPair x, y, 1, -1
        bottomRight = getVertexPair x + 1, y, -1, -1
        
        indices.push bottomLeft.topIndex, bottomLeft.bottomIndex, bottomRight.bottomIndex, bottomRight.topIndex, bottomLeft.topIndex, bottomRight.bottomIndex
        
        indices.push topLeft.topIndex, bottomRight.topIndex, topRight.topIndex, topLeft.topIndex, bottomLeft.topIndex, bottomRight.topIndex
        indices.push bottomRight.bottomIndex, topLeft.bottomIndex, topRight.bottomIndex, bottomLeft.bottomIndex, topLeft.bottomIndex, bottomRight.bottomIndex
        
      alpha = newAlpha
    
  for y in [0...imageData.height]
    alpha = 0
  
    for x in [0...imageData.width]
      pixelOffset = (x + y * imageData.width) * 4
      newAlpha = imageData.data[pixelOffset + 3]
      
      if newAlpha and not alpha
        # A new stripe starts.
        topLeft = getVertexPair x, y, 1, 1
        bottomLeft = getVertexPair x, y + 1, 1, -1
        
        indices.push topLeft.topIndex, topLeft.bottomIndex, bottomLeft.topIndex, topLeft.bottomIndex, bottomLeft.bottomIndex, bottomLeft.topIndex
      
      else if alpha and not newAlpha
        # The stripe ended.
        topRight = getVertexPair x, y, -1, 1
        bottomRight = getVertexPair x, y + 1, -1, -1
        
        indices.push topRight.bottomIndex, topRight.topIndex, bottomRight.bottomIndex, topRight.topIndex, bottomRight.topIndex, bottomRight.bottomIndex
        
      alpha = newAlpha
  
  vertexBufferArray =  new Float32Array vertexPairs.length * 2 * 3
  uvBufferArray =  new Float32Array vertexPairs.length * 2 * 2
  
  for vertexPair, vertexPairIndex in vertexPairs
    vertexPairOffset = vertexPairIndex * 6
    vertexBufferArray[vertexPairOffset] = vertexPair.x * pixelSize - corner.x
    vertexBufferArray[vertexPairOffset + 1] = corner.y - vertexPair.y * pixelSize
    vertexBufferArray[vertexPairOffset + 2] = corner.z
    vertexBufferArray[vertexPairOffset + 3] = vertexBufferArray[vertexPairOffset]
    vertexBufferArray[vertexPairOffset + 4] = vertexBufferArray[vertexPairOffset + 1]
    vertexBufferArray[vertexPairOffset + 5] = -corner.z
    
    vertexPairOffset = vertexPairIndex * 4
    uvBufferArray[vertexPairOffset] = (vertexPair.x + vertexPair.offsetU * 0.01) / imageData.width
    uvBufferArray[vertexPairOffset + 1] = 1 - (vertexPair.y + vertexPair.offsetV * 0.01) / imageData.height
    uvBufferArray[vertexPairOffset + 2] = uvBufferArray[vertexPairOffset]
    uvBufferArray[vertexPairOffset + 3] = uvBufferArray[vertexPairOffset + 1]
  
  geometry = new THREE.BufferGeometry
  geometry.setAttribute 'position', new THREE.BufferAttribute vertexBufferArray, 3
  geometry.setAttribute 'uv', new THREE.BufferAttribute uvBufferArray, 2
  geometry.setIndex new THREE.BufferAttribute new Uint32Array(indices), 1
  geometry.computeBoundingBox()
  geometry
