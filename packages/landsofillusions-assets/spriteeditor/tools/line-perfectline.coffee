LOI = LandsOfIllusions

LOI.Assets.SpriteEditor.Tools.Line.perfectLine = (start, end, fractional, mirrored) ->
  dx = end.x - start.x
  dy = end.y - start.y
  
  absoluteDx = Math.abs dx
  absoluteDy = Math.abs dy
  
  # Don't allow lines with just 2 segments so it's easier to constrain to straight lines.
  unless mirrored
    if absoluteDx is 1 and absoluteDy > 3
      dx = 0
      absoluteDx = 0
    
    if absoluteDy is 1 and absoluteDx > 3
      dy = 0
      absoluteDy = 0
    
  width = absoluteDx + 1
  height = absoluteDy + 1

  # We need to calculate the ratio based on the total size which will be doubled with mirrored lines.
  if mirrored
    totalWidth = 2 * absoluteDx + 1
    totalHeight = 2 * absoluteDy + 1

  else
    totalWidth = width
    totalHeight = height

  if totalWidth > totalHeight
    ratio = totalWidth / totalHeight

  else
    ratio = totalHeight / totalWidth
    vertical = true
    
  if ratio < 3 and fractional
    # Allow for fractional lines with multiple segment lengths.
    doubleRatio = Math.round ratio * 2
    segmentLengths = [Math.ceil(doubleRatio / 2), Math.floor(doubleRatio / 2)]

    if segmentLengths[0] is segmentLengths[1]
      denominator = 1
      numerator = segmentLengths[0]

    else
      denominator = 2
      numerator = segmentLengths[0] + segmentLengths[1]

  else
    numerator = Math.round ratio
    denominator = 1
    segmentLengths = [numerator]

  # Calculate the ratio numbers.
  if width > 1 and height > 1
    if vertical
      ratio = [denominator, numerator]

    else
      ratio = [numerator, denominator]

  else
    # There is no ratio for straight lines.
    ratio = null

  # Generate the pixels.
  sx = Math.sign dx
  sy = Math.sign dy

  lengthLeft = Math.max width, height
  sideLeft = Math.min width, height

  currentPixel = _.pick start, ['x', 'y']

  segmentLengthIndex = 0
  segmentLeft = segmentLengths[segmentLengthIndex]

  if mirrored
    mirroredStart = _.clone start
    
    unless segmentLeft % 2
      if vertical
        mirroredStart.y -= sy
        
      else
        mirroredStart.x -= sx
        
    segmentLeft = Math.ceil segmentLeft / 2
    
  pixels = []
  
  addPixelCoordinate = (x, y) ->
    pixels.push {x, y}

  while lengthLeft and sideLeft
    if mirrored
      mirroredX = mirroredStart.x - (currentPixel.x - start.x)
      mirroredY = mirroredStart.y - (currentPixel.y - start.y)
      
      addPixelCoordinate mirroredX, mirroredY unless mirroredX is start.x and mirroredY is start.y

    addPixelCoordinate currentPixel.x, currentPixel.y

    # Mark progress along segment and length.
    segmentLeft--
    lengthLeft--

    # Move ahead along length.
    if vertical
      currentPixel.y += sy

    else
      currentPixel.x += sx

    continue if segmentLeft

    # Step sideways.
    if vertical
      currentPixel.x += sx

    else
      currentPixel.y += sy

    sideLeft--
    segmentLengthIndex = (segmentLengthIndex + 1) % segmentLengths.length
    segmentLeft = segmentLengths[segmentLengthIndex]
  
  {pixels, ratio}
