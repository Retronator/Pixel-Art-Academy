LOI = LandsOfIllusions

class LOI.Engine.Textures.Sprite
  constructor: (sprite) ->
    @update sprite if sprite
    
  update: (sprite) ->
    width = sprite.bounds.width
    height = sprite.bounds.height

    # Create data textures.
    paletteColorData = new Uint8Array width * height * 4
    @paletteColorTexture = new THREE.DataTexture paletteColorData, width, height, THREE.RGBAFormat

    normalData = new Uint8Array width * height * 3
    @normalTexture = new THREE.DataTexture normalData, width, height, THREE.RGBFormat

    for layer in sprite.layers when layer?.pixels and layer.visible isnt false
      layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0
        z: layer.origin?.z or 0

      for pixel in layer.pixels
        # Find pixel index in the image buffer.
        x = pixel.x + layerOrigin.x - sprite.bounds.x
        y = pixel.y + layerOrigin.y - sprite.bounds.y
        pixelIndex = x + y * width

        paletteColor = null

        if pixel.materialIndex?
          paletteColor = sprite.materials[pixel.materialIndex]

        else if pixel.paletteColor
          paletteColor = pixel.paletteColor

        if paletteColor
          paletteColorData[pixelIndex * 4] = paletteColor.ramp
          paletteColorData[pixelIndex * 4 + 1] = paletteColor.shade

        if pixel.normal
          normalData[pixelIndex * 3] = (pixel.normal.x + 1) * 127
          normalData[pixelIndex * 3 + 1] = (pixel.normal.y + 1) * 127
          normalData[pixelIndex * 3 + 2] = (pixel.normal.z + 1) * 127

    for texture in [@paletteColorTexture, @normalTexture]
      texture.needsUpdate = true
