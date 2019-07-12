LOI = LandsOfIllusions

class LOI.Engine.Textures.Sprite
  @generateData: (sprite) ->
    width = sprite.bounds.width
    height = sprite.bounds.height

    # Create data textures.
    paletteColorData = new Uint8Array width * height * 4
    normalData = new Uint8Array width * height * 3

    for layer in sprite.layers when layer?.pixels and layer.visible isnt false
      layerOrigin =
        x: layer.origin?.x or 0
        y: layer.origin?.y or 0
        z: layer.origin?.z or 0

      for pixel in layer.pixels
        # Find pixel index in the image buffer. Textures have origin
        # in the bottom-left corner, so we have to flip the Y direction.
        x = pixel.x + layerOrigin.x - sprite.bounds.left
        y = sprite.bounds.bottom - (pixel.y + layerOrigin.y)
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

    {paletteColorData, normalData}

  constructor: (sprite, @options = {}) ->
    @update sprite if sprite
    
  update: (sprite) ->
    width = sprite.bounds.width
    height = sprite.bounds.height
    @isPowerOf2 = (width & (width - 1)) is 0 and (height & (height - 1)) is 0

    {paletteColorData, normalData} = LOI.Engine.Textures.Sprite.generateData sprite

    # Create data textures.
    @paletteColorTexture = new THREE.DataTexture paletteColorData, width, height, THREE.RGBAFormat
    @normalTexture = new THREE.DataTexture normalData, width, height, THREE.RGBFormat

    for texture in [@paletteColorTexture, @normalTexture]
      if @isPowerOf2
        texture.wrapS = THREE.RepeatWrapping
        texture.wrapT = THREE.RepeatWrapping

      # See if any of the filters are set to linear (nearest is default for data textures).
      texture.minFilter = THREE.LinearFilter if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear
      texture.magFilter = THREE.LinearFilter if @options.magnificationFilter is LOI.Assets.Mesh.TextureFilters.Linear

      texture.anisotropy = if @options.anisotropicFiltering then LOI.settings.graphics.anisotropicFilteringSamples.value() or 0

      texture.needsUpdate = true
