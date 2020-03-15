LOI = LandsOfIllusions

class LOI.Engine.RadianceState
  @radianceAtlasProbeLevel: 3
  @radianceAtlasProbeResolution: 2 ** @radianceAtlasProbeLevel

  @initialize: ->
    # Prepare rendering the probe.
    @Probe.initialize()

    # Prepare rendering of radiance atlases.
    @modelViewProjectionMatrix = new THREE.Matrix4

    radianceMaterialOptions =
      modelViewProjectionMatrix: @modelViewProjectionMatrix

    @radianceMaterialIn = new @RadianceMaterial.In radianceMaterialOptions
    @radianceMaterialOut = new @RadianceMaterial.Out radianceMaterialOptions

    @radianceAtlasQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(), @radianceMaterialIn
    @radianceAtlasQuad.position.z = -1

    @radianceAtlasScene = new THREE.Scene()
    @radianceAtlasScene.add @radianceAtlasQuad

  @updateRadianceAtlas: (renderer, pixelCoordinates, radianceAtlas, radianceAtlasCamera, clear) ->
    # Update probe map.
    @Probe.update renderer

    # Position the update quad over the destination.
    @radianceAtlasQuad.position.x = pixelCoordinates.x + 0.5
    @radianceAtlasQuad.position.y = pixelCoordinates.y + 0.5
    @radianceAtlasQuad.updateWorldMatrix()

    @modelViewProjectionMatrix.copy(@radianceAtlasQuad.matrixWorld).premultiply(radianceAtlasCamera.projectionMatrix)

    # Transfer probe radiance to radiance in atlas.
    renderer.setRenderTarget radianceAtlas.in

    if clear
      renderer.setClearColor 0, 0
      renderer.clearColor()

    @radianceAtlasQuad.material = @radianceMaterialIn
    renderer.render @radianceAtlasScene, radianceAtlasCamera

    # Transfer probe radiance to radiance out atlas.
    renderer.setRenderTarget radianceAtlas.out
    renderer.clearColor() if clear

    @radianceAtlasQuad.material = @radianceMaterialOut
    renderer.render @radianceAtlasScene, radianceAtlasCamera

  constructor: (@cluster) ->
    boundsInPicture = @cluster.boundsInPicture()
    @width = boundsInPicture.width
    @height = boundsInPicture.height

    pictureCluster = @cluster.layer.getPictureCluster @cluster.id
    pictureBounds = pictureCluster.picture.bounds()

    @absoluteClusterPosition =
      x: pictureBounds.x + boundsInPicture.x
      y: pictureBounds.y + boundsInPicture.y

    # Create in and out textures.
    @textureSize =
      width: @width * @constructor.radianceAtlasProbeResolution
      height: @height * @constructor.radianceAtlasProbeResolution * 2

    @radianceAtlas =
      in: @_createRadianceAtlas()
      out: @_createRadianceAtlas()

    # Create probe map (which radiance probe should a certain pixel use).
    @probeMap = new @constructor.ProbeMap @cluster

    @cameraAngle = @cluster.layer.object.mesh.cameraAngles.get 0

    @radianceAtlasCamera = new THREE.OrthographicCamera 0, @width, @height, 0, 0.5, 1.5

  destroy: ->
    @radianceAtlas.in.dispose()
    @radianceAtlas.out.dispose()

  _createRadianceAtlas: ->
    new THREE.WebGLRenderTarget @textureSize.width, @textureSize.height,
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false
      minFilter: THREE.LinearFilter
      magFilter: THREE.NearestFilter

  update: (renderer, scene) ->
    # Calculate how many probes to update.
    updateCount = Math.floor @textureSize.width * @textureSize.height / 100
    updated = 0

    probeCubeCamera = @constructor.Probe.cubeCamera

    for i in [0...updateCount]
      return updated unless pixelCoordinates = @probeMap.getNewUpdatePixel()

      # Put the camera into plane's basis (z points away from the cluster surface).
      probeCubeCamera.setRotationFromMatrix @cluster.planeBasis

      # Place the camera on the spot on the cluster where we should render from.
      absolutePixelCoordinates =
        x: @absoluteClusterPosition.x + pixelCoordinates.x
        y: @absoluteClusterPosition.y + pixelCoordinates.y

      @cameraAngle.projectPoint absolutePixelCoordinates, @cluster.planeHelper, 0, 0, probeCubeCamera.position

      # Render the probe cube.
      renderer.setClearColor 0, 1
      probeCubeCamera.clear renderer
      probeCubeCamera.update renderer, scene

      # Update the radiance atlas.
      @constructor.updateRadianceAtlas renderer, pixelCoordinates, @radianceAtlas, @radianceAtlasCamera, not @_performedInitialClear
      @_performedInitialClear = true

      updated++

    updated
