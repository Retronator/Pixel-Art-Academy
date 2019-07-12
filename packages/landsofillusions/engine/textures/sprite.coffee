LOI = LandsOfIllusions

class LOI.Engine.Textures.Sprite
  @_texturesCache = []
  @_spriteDataCache = {}
  @_spriteDataCacheDependency = new Tracker.Dependency

  @getTextures: (options) ->
    # Strip options to relevant properties.
    relevantOptions = @getRelevantOptions options

    # Try to find a texture with these options in the cache.
    texturesEntry = _.find @_texturesCache, (texturesEntry) => _.isEqual texturesEntry.options, relevantOptions
    return texturesEntry.textures if texturesEntry

    # Create new sprite textures.
    spriteTextures = new LOI.Engine.Textures.Sprite relevantOptions
    @_texturesCache.push
      options: relevantOptions
      textures: spriteTextures

    spriteTextures

  @getRelevantOptions: (options) ->
    _.pick options, ['spriteId', 'spriteName', 'anisotropicFiltering', 'minificationFilter', 'magnificationFilter', 'mipmapFilter']

  @getData: (options) ->
    # We only care about the sprite address when getting data.
    spriteAddress = options.spriteId or options.spriteName

    # Try to find a texture with these options in the cache.
    if spriteData = @_spriteDataCache[spriteAddress]
      return spriteData

    # Create the new sprite data object. We need two dependencies, one when sprite size changes and
    # we need to return completely new buffers, and one when only the content of the buffer changes.
    mainDependency = new Tracker.Dependency
    dataContentDependency = new Tracker.Dependency

    spriteData =
      depend: => mainDependency.depend()
      dependOnDataContent: => dataContentDependency.depend()

    Tracker.nonreactive =>
      Tracker.autorun (computation) =>
        # Find the sprite in cache or documents. Try documents first so we can get live updates.
        sprite = LOI.Assets.Sprite.documents.findOne
          $or: [
            _id: options.spriteId
          ,
            name: options.spriteName
          ]

        unless sprite
          if options.spriteId
            sprite = LOI.Assets.Sprite.getFromCache options.spriteId

          else
            sprite = LOI.Assets.Sprite.findInCache name: options.spriteName

        return unless sprite?.bounds

        unless sprite.bounds.width is spriteData.width and sprite.bounds.height is spriteData.height
          # We need to create new buffers.
          spriteData.width = sprite.bounds.width
          spriteData.height = sprite.bounds.height
          spriteData.isPowerOf2 = (spriteData.width & (spriteData.width - 1)) is 0 and (spriteData.height & (spriteData.height - 1)) is 0

          spriteData.paletteColorData = new Uint8Array spriteData.width * spriteData.height * 4
          spriteData.normalData = new Uint8Array spriteData.width * spriteData.height * 3
          buffersChanged = true

        @_fillData sprite, spriteData.paletteColorData, spriteData.normalData

        # Trigger correct dependency.
        if buffersChanged
          mainDependency.changed()

        else
          dataContentDependency.changed()

    @_spriteDataCache[spriteAddress] = spriteData
    @_spriteDataCacheDependency.changed()

    spriteData

  @_fillData: (sprite, paletteColorData, normalData) ->
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
        pixelIndex = x + y * sprite.bounds.width

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

  @depend: ->
    @_spriteDataCacheDependency.depend()

    for spriteAddress, spriteData of @_spriteDataCache
      spriteData.depend()
      spriteData.dependOnDataContent()

  constructor: (@options) ->
    @_dependency = new Tracker.Dependency

    # Keep updating the texture data.
    Tracker.nonreactive =>
      Tracker.autorun (computation) =>
        @update()

  depend: ->
    @_dependency.depend()
    
  update: ->
    spriteData = LOI.Engine.Textures.Sprite.getData @options
    spriteData.depend()

    # Create data textures.
    @paletteColorTexture = new THREE.DataTexture spriteData.paletteColorData, spriteData.width, spriteData.height, THREE.RGBAFormat
    @normalTexture = new THREE.DataTexture spriteData.normalData, spriteData.width, spriteData.height, THREE.RGBFormat

    @isPowerOf2 = spriteData.isPowerOf2

    for texture in [@paletteColorTexture, @normalTexture]
      if @isPowerOf2
        # We can use coordinate wrapping.
        texture.wrapS = THREE.RepeatWrapping
        texture.wrapT = THREE.RepeatWrapping

      # See if any of the filters are set to linear (nearest is default for data textures).
      texture.minFilter = THREE.LinearFilter if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear
      texture.magFilter = THREE.LinearFilter if @options.magnificationFilter is LOI.Assets.Mesh.TextureFilters.Linear

      texture.anisotropy = if @options.anisotropicFiltering then LOI.settings.graphics.anisotropicFilteringSamples.value() or 0

      texture.needsUpdate = true

    # Update data independently when data buffer content changes (but not the buffers themselves).
    @_dataContentUpdateAutorun?.stop()

    Tracker.nonreactive =>
      @_dataContentUpdateAutorun = Tracker.autorun (computation) =>
        spriteData.dependOnDataContent()
        texture.needsUpdate = true for texture in [@paletteColorTexture, @normalTexture]

    @_dependency.changed()
