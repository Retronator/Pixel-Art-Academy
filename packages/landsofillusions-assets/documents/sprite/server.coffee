AE = Artificial.Everywhere
LOI = LandsOfIllusions
PNG = Npm.require('pngjs').PNG
Request = request

WebApp.connectHandlers.use '/assets/sprite.png', (request, response, next) ->
  query = request.query
  
  sprite = LOI.Assets.Sprite.documents.findOne query.spriteId
  throw new AE.ArgumentException "Sprite not found." unless sprite

  palette = sprite.customPalette

  if sprite.palette and not palette
    palette = LOI.Assets.Palette.documents.findOne sprite.palette._id
    throw new AE.InvalidOperationException "Sprite palette not found." unless palette

  # Create the PNG
  png = new PNG
    width: sprite.bounds.width
    height: sprite.bounds.height

  depthBuffer = new Float32Array png.width * png.height

  # Clear the depth buffer to smallest value.
  depthBuffer.fill Number.NEGATIVE_INFINITY

  for layer in sprite.layers
    continue unless layer.pixels

    layerOrigin =
      x: layer.origin?.x or 0
      y: layer.origin?.y or 0
      z: layer.origin?.z or 0

    for pixel in layer.pixels
      # Find pixel index in the image buffer.
      x = pixel.x + layerOrigin.x - sprite.bounds.x
      y = pixel.y + layerOrigin.y - sprite.bounds.y
      depthPixelIndex = x + y * png.width
      pixelIndex = depthPixelIndex * 4

      # Cull by depth.
      z = layerOrigin.z + (pixel.z or 0)
      continue if z < depthBuffer[depthPixelIndex]

      # Update depth buffer.
      depthBuffer[depthPixelIndex] = z

      # Determine the color.
      if pixel.paletteColor
        shades = palette.ramps[pixel.paletteColor.ramp].shades
        shadeIndex = THREE.Math.clamp pixel.paletteColor.shade, 0, shades.length - 1
        color = shades[shadeIndex]

      else if pixel.directColor
        color = pixel.directColor

      png.data[pixelIndex] = color.r * 255
      png.data[pixelIndex + 1] = color.g * 255
      png.data[pixelIndex + 2] = color.b * 255
      png.data[pixelIndex + 3] = 255

  buffer = PNG.sync.write png

  response.writeHead 200, 'Content-Type': 'image/png'
  response.end buffer
