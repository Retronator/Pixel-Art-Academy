PNG = Npm.require('pngjs').PNG
Request = request

WebApp.connectHandlers.use '/pico8.png', (request, response, next) ->
  query = request.query
  cartridgeUrl = query.cartridge

  result = Request.getSync cartridgeUrl, encoding: null

  png = PNG.sync.read result.body

  # Create the 128x128 indexed sprite sheet (each cell is a color index from 0-15).
  spriteRow = (0 for i in [0...128])
  spriteSheet = (spriteRow for i in [0..128])

  spriteSheet = for i in [0..128]
    for i in [0..128]
      0

  # Calculate how many rows of the png do we need to read to get our spritesheet information.
  spriteSheetMemorySize = 128 * 128 / 2
  neededRows = Math.ceil spriteSheetMemorySize / png.width

  for y in [0..neededRows]
    for x in [0..png.width]
      # Get the png pixel index.
      pngPixelIndex = x + y * png.width

      # Get the low 2 bits of each channel. Together we have 4 x 2 bits = 1 byte
      # of information that corresponds to one pico-8 memory value.
      r = png.data[pngPixelIndex * 4] & 3
      g = png.data[pngPixelIndex * 4 + 1] & 3
      b = png.data[pngPixelIndex * 4 + 2] & 3
      a = png.data[pngPixelIndex * 4 + 3] & 3

      # Combine the 4 x 2 bits into the full 1 byte.
      memoryValue = (a << 6) | (r << 4) | (g << 2) | b

      # One memory location holds two sprite sheet pixels: left in low bits and right in high bits.
      rightIndex = (memoryValue & 240) >> 4
      leftIndex = memoryValue & 15

      # Calculate sprite sheet location of the left pixel.
      spriteX = (pngPixelIndex * 2) % 128
      spriteY = Math.floor (pngPixelIndex * 2) / 128

      break if spriteY > 128

      spriteSheet[spriteX][spriteY] = leftIndex
      spriteSheet[spriteX + 1][spriteY] = rightIndex

  # Rewrite the sprites with random colors.
  for x in [0...128]
    for y in [0...128]
      spriteSheet[x][y] = (Math.floor(x / 8) + Math.floor(y / 8)) % 16

  ### DEBUG: Write out the top 8x8 sprites.
  console.log ""
  console.log "SPRITE SHEET:"
  for y in [0...128]
    rowArray = (indexString = spriteSheet[x][y].toString(16) for x in [0...128])
    console.log rowArray.join('')
  ###

  # Write indexed sprite sheet back into the PNG. Each two sprite pixels contribute to one png pixel.
  for x in [0...64]
    for y in [0...128]
      leftIndex = spriteSheet[x * 2][y]
      rightIndex = spriteSheet[x * 2 + 1][y]

      # Combine two indices into pico-8 memory value.
      memoryValue = leftIndex | (rightIndex << 4)

      # Distribute 8 bits into 4 x 2 bits for encoding into colors.
      a = (memoryValue & (3 << 6)) >> 6
      r = (memoryValue & (3 << 4)) >> 4
      g = (memoryValue & (3 << 2)) >> 2
      b = memoryValue & 3

      # Replace the lower two bits in each png pixel channel.
      spritePixelIndex = y * 128 + x * 2
      pngPixelIndex = Math.floor spritePixelIndex / 2

      png.data[pngPixelIndex * 4] = (png.data[pngPixelIndex * 4] & 252) | r
      png.data[pngPixelIndex * 4 + 1] = (png.data[pngPixelIndex * 4 + 1] & 252) | g
      png.data[pngPixelIndex * 4 + 2] = (png.data[pngPixelIndex * 4 + 2] & 252) | b
      png.data[pngPixelIndex * 4 + 3] = (png.data[pngPixelIndex * 4 + 3] & 252) | a

  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
