LOI = LandsOfIllusions

class LOI.Engine.RadianceState
  @probeResolution: 4

  constructor: (@cluster) ->
    boundsInPicture = @cluster.boundsInPicture()

    # Create in and out textures.
    @textureSize =
      width: boundsInPicture.width * LOI.Engine.RadianceState.probeResolution
      height: boundsInPicture.height * LOI.Engine.RadianceState.probeResolution * 2

    @radianceAtlas =
      in: @_createRadianceAtlas()
      out: @_createRadianceAtlas()

    # Create probe map (which radiance probe should a certain pixel use).
    @probeMap = new @constructor.ProbeMap @cluster
    @probeMap.debugOutput()

    @cameraAngle = @cluster.layer.object.mesh.cameraAngles.get 0

  destroy: ->
    @radianceAtlas.in.dispose()
    @radianceAtlas.out.dispose()

  _createRadianceAtlas: ->
    new THREE.WebGLRenderTarget @textureSize.width, @textureSize.height,
      format: THREE.RGBFormat
      type: THREE.FloatType
      stencilBuffer: false

  update: (cubeCamera, renderer, scene) ->
    # Calculate how many probes to update.
    loopCount = Math.floor @textureSize.width * @textureSize.height / 100
    updated = 0

    for i in [0...loopCount]
      # Place the camera on the spot on the cluster where we should render from.
      return updated unless pixelCoordinates = @probeMap.getNewUpdatePixel()

      @cameraAngle.projectPoint pixelCoordinates, @cluster.planeHelper, 0, 0, cubeCamera.position

      renderer.setClearColor 0xaaaa33, 1
      cubeCamera.clear renderer

      cubeCamera.update renderer, scene
      updated++

    updated
