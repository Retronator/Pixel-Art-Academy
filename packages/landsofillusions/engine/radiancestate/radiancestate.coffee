LOI = LandsOfIllusions

class LOI.Engine.RadianceState
  @probeResolution: 4

  constructor: (@options) ->
    # Create in and out textures.
    @textureSize =
      width: @options.size.width * LOI.Engine.RadianceState.probeResolution
      height: @options.size.height * LOI.Engine.RadianceState.probeResolution * 2

    @radianceAtlas =
      in: @_createRadianceAtlas()
      out: @_createRadianceAtlas()

    # Create probe map (which radiance probe should a certain pixel use).
    @probeMap = new @constructor.ProbeMap @options

  destroy: ->
    @radianceAtlas.in.dispose()
    @radianceAtlas.out.dispose()

  _createRadianceAtlas: ->
    new THREE.WebGLRenderTarget @textureSize.width, @textureSize.height,
      format: THREE.RGBFormat
      type: THREE.FloatType
      stencilBuffer: false
