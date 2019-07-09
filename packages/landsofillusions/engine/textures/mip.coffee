LOI = LandsOfIllusions

class LOI.Engine.Textures.Mip
  constructor: (mipPath) ->
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
    _.sortBy mipmaps, (mipmap) => -(mipmap.bounds?.width or 0)

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
        texture.wrapS = THREE.RepeatWrapping
        texture.wrapT = THREE.RepeatWrapping
        texture.minFilter = THREE.LinearMipMapLinearFilter
        texture.anisotropy = 16

      texture.needsUpdate = true
