LOI = LandsOfIllusions

class LOI.Engine.Textures.Mip
  @_texturesCache = []
  @_spriteDataCache = {}

  @getTextures: (options) ->
    # Strip options to relevant properties.
    relevantOptions = LOI.Engine.Textures.Sprite.getRelevantOptions options

    # Try to find a texture with these options in the cache.
    texturesEntry = _.find @_texturesCache, (texturesEntry) => _.isEqual texturesEntry.options, relevantOptions
    return texturesEntry.textures if texturesEntry

    # Create new sprite textures.
    spriteTextures = new LOI.Engine.Textures.Mip relevantOptions
    @_texturesCache.push
      options: relevantOptions
      textures: spriteTextures

    spriteTextures

  constructor: (@options = {}) ->
    @_dependency = new Tracker.Dependency

    # Keep updating the texture data.
    Tracker.nonreactive =>
      Tracker.autorun (computation) =>
        @update()

  depend: ->
    @_dependency.depend()

  update: ->
    # Find sprites in cache or documents.
    escapedSpriteName = @options.spriteName.replace /\//g, '\\/'

    mipmaps = LOI.Assets.Sprite.documents.fetch
      name: ///^#{escapedSpriteName}\/.*///
      # Make sure the returned sprites are fully loaded (they will be missing bounds otherwise)
      bounds: $exists: true
    ,
      # Only react to bounds changes since otherwise only the internal buffers need to be updated.
      fields:
        bounds: 1

    unless mipmaps.length
      mipmaps = LOI.Assets.Sprite.findAllInCache (sprite) =>
        _.startsWith sprite.name, @options.spriteName

    return unless mipmaps.length

    # Sort largest width to smallest.
    mipmaps = _.sortBy mipmaps, (mipmap) => -(mipmap.bounds?.width or 0)

    # Create data textures.
    sprite = _.first mipmaps

    spriteData = LOI.Engine.Textures.Sprite.getData spriteId: sprite._id
    spriteData.depend()

    mipmapSpriteData = [spriteData]

    # Create data textures.
    @paletteColorTexture = new THREE.DataTexture spriteData.paletteColorData, spriteData.width, spriteData.height, THREE.RGBAFormat
    @normalTexture = new THREE.DataTexture spriteData.normalData, spriteData.width, spriteData.height, THREE.RGBFormat

    @isPowerOf2 = spriteData.isPowerOf2
    console.warn "Mip textures must be power of 2" unless @isPowerOf2

    # Only add mipmaps if we have a full chain of power-of-two textures.
    requiredMipmapsCount = 1 + Math.log2 sprite.bounds.width
    validMipmaps = @isPowerOf2 and mipmaps.length is requiredMipmapsCount

    if validMipmaps
      # Add the main data as the first mipmap.
      @paletteColorTexture.mipmaps.push
        width: spriteData.width
        height: spriteData.height
        data: spriteData.paletteColorData

      @normalTexture.mipmaps.push
        width: spriteData.width
        height: spriteData.height
        data: spriteData.normalData

      # Add the rest of the mipmaps.
      for mipmap in mipmaps[1..]
        mipmapData = LOI.Engine.Textures.Sprite.getData spriteId: mipmap._id
        mipmapData.depend()

        mipmapSpriteData.push mipmapData

        continue unless mipmapData.width

        @paletteColorTexture.mipmaps.push
          width: mipmapData.width
          height: mipmapData.height
          data: mipmapData.paletteColorData

        @normalTexture.mipmaps.push
          width: mipmapData.width
          height: mipmapData.height
          data: mipmapData.normalData

    for texture in [@paletteColorTexture, @normalTexture]
      if @isPowerOf2
        # We can use coordinate wrapping.
        texture.wrapS = THREE.RepeatWrapping
        texture.wrapT = THREE.RepeatWrapping

      if validMipmaps
        # We can use mipmapping. See if any of the filters are set to linear (nearest is default for data textures).
        if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear and @options.mipmapFilter is LOI.Assets.Mesh.TextureFilters.Linear
          texture.minFilter = THREE.LinearMipmapLinearFilter

        else if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear
          texture.minFilter = THREE.LinearMipmapNearestFilter

        else if @options.mipmapFilter is LOI.Assets.Mesh.TextureFilters.Linear
          texture.minFilter = THREE.NearestMipmapLinearFilter

        else
          texture.minFilter = THREE.NearestMipmapNearestFilter

      else
        # The textures are not power of two so we can't use mipmap filters.
        texture.minFilter = THREE.LinearFilter if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear

      texture.magFilter = THREE.LinearFilter if @options.magnificationFilter is LOI.Assets.Mesh.TextureFilters.Linear

      texture.anisotropy = if @options.anisotropicFiltering then LOI.settings.graphics.anisotropicFilteringSamples.value() or 0

      texture.needsUpdate = true

    # Update data independently when data buffer content changes (but not the buffers themselves).
    @_dataContentUpdateAutorun?.stop()

    Tracker.nonreactive =>
      @_dataContentUpdateAutorun = Tracker.autorun (computation) =>
        # If any of the mipmaps' content changes, update this texture.
        spriteData.dependOnDataContent() for spriteData in mipmapSpriteData

        texture.needsUpdate = true for texture in [@paletteColorTexture, @normalTexture]

    @_dependency.changed()
