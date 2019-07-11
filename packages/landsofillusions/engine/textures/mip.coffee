LOI = LandsOfIllusions

class LOI.Engine.Textures.Mip
  constructor: (mipPath, @options = {}) ->
    @update mipPath if mipPath
    
  update: (mipPath) ->
    # Find sprites in cache or documents.
    mipmaps = LOI.Assets.Sprite.findAllInCache (sprite) =>
      _.startsWith sprite.name, mipPath

    unless mipmaps.length
      escapedFileId = mipPath.replace /\//g, '\\/'

      mipmaps = LOI.Assets.Sprite.documents.fetch
        name: ///^#{escapedFileId}\/.*///

    return unless mipmaps.length

    # Sort largest width to smallest.
    mipmaps = _.sortBy mipmaps, (mipmap) => -(mipmap.bounds?.width or 0)

    # Create data textures.
    sprite = _.first mipmaps

    width = sprite.bounds.width
    height = sprite.bounds.height
    @isPowerOf2 = (width & (width - 1)) is 0 and (height & (height - 1)) is 0
    console.warn "Mip textures must be power of 2" unless @isPowerOf2

    {paletteColorData, normalData} = LOI.Engine.Textures.Sprite.generateData sprite

    @paletteColorTexture = new THREE.DataTexture paletteColorData, width, height, THREE.RGBAFormat
    @normalTexture = new THREE.DataTexture normalData, width, height, THREE.RGBFormat

    # Add the main data as the first mipmap.
    @paletteColorTexture.mipmaps.push {width, height, data: paletteColorData}
    @normalTexture.mipmaps.push {width, height, data: normalData}

    # Add the rest of the mipmaps.
    for mipmap in mipmaps[1..]
      {paletteColorData, normalData} = LOI.Engine.Textures.Sprite.generateData mipmap

      @paletteColorTexture.mipmaps.push
        width: mipmap.bounds.width
        height: mipmap.bounds.height
        data: paletteColorData

      @normalTexture.mipmaps.push
        width: mipmap.bounds.width
        height: mipmap.bounds.height
        data: normalData

    for texture in [@paletteColorTexture, @normalTexture]
      if @isPowerOf2
        # We can use mipmapping and coordinate wrapping.
        texture.wrapS = THREE.RepeatWrapping
        texture.wrapT = THREE.RepeatWrapping

        # See if any of the filters are set to linear (nearest is default for data textures).
        if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear and @options.mipmapFilter is LOI.Assets.Mesh.TextureFilters.Linear
          texture.minFilter = THREE.LinearMipMapLinearFilter

        else if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear
          texture.minFilter = THREE.LinearMipMapNearestFilter

        else if @options.mipmapFilter is LOI.Assets.Mesh.TextureFilters.Linear
          texture.minFilter = THREE.NearestMipMapLinearFilter

        else
          texture.minFilter = THREE.NearestMipMapNearestFilter

      else
        # The textures are not power of two so we can't use mipmap filters.
        texture.minFilter = THREE.LinearFilter if @options.minificationFilter is LOI.Assets.Mesh.TextureFilters.Linear

      texture.magFilter = THREE.LinearFilter if @options.magnificationFilter is LOI.Assets.Mesh.TextureFilters.Linear

      texture.anisotropy = if @options.anisotropicFiltering then LOI.settings.graphics.anisotropicFilteringSamples.value() or 0

      texture.needsUpdate = true
