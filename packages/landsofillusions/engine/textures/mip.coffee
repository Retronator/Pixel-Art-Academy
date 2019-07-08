LOI = LandsOfIllusions

class LOI.Engine.Textures.Mip
  constructor: (mipPath) ->
    @update mipPath if mipPath
    
  update: (mipPath) ->
    # Find sprites in cache or documents.
    mipmaps = LOI.Assets.Sprite.findInCache (sprite) =>
      _.startsWith sprite.name, mipPath

    unless mipmaps.length
      escapedFileId = mipPath.replace /\//g, '\\/'

      mipmaps = LOI.Assets.Sprite.documents.fetch
        name: ///^#{escapedFileId}\/.*///

    return unless mipmaps.length

    # Sort largest width to smallest.
    _.sortBy mipmaps, (mipmap) => -(mipmap.bounds?.width or 0)

    @spriteTextures = for mipmap in mipmaps
      # Create the sprite textures.
      new LOI.Engine.Textures.Sprite mipmap

    sprite = _.first mipmaps

    width = sprite.bounds.width
    height = sprite.bounds.height

    {paletteColorData, normalData} = LOI.Engine.Textures.Sprite.generateData sprite

    # Create data textures.
    @paletteColorTexture = new THREE.DataTexture paletteColorData, width, height, THREE.RGBAFormat
    @normalTexture = new THREE.DataTexture normalData, width, height, THREE.RGBFormat

    @paletteColorTexture.mipmaps.push {width, height, data: paletteColorData}
    @normalTexture.mipmaps.push {width, height, data: normalData}

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
      texture.wrapS = THREE.RepeatWrapping
      texture.wrapT = THREE.RepeatWrapping
      texture.minFilter = THREE.NearestMipMapNearestFilter
      texture.needsUpdate = true
