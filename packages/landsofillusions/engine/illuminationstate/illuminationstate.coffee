LOI = LandsOfIllusions

class LOI.Engine.IlluminationState
  @initialize: ->
    # Prepare rendering of illumination atlases.
    @modelViewProjectionMatrix = new THREE.Matrix4

    @illuminationMaterial = new @IlluminationMaterial
      modelViewProjectionMatrix: @modelViewProjectionMatrix

    @lightmapQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(), @illuminationMaterial
    @lightmapQuad.position.z = -1

    @lightmapScene = new THREE.Scene()
    @lightmapScene.add @lightmapQuad

  @updateLightmap: (renderer, lightmapCoordinates, lightmapMipmapLevel, lightmap, lightmapCamera, clear) ->
    # Update probe map.
    LOI.Engine.RadianceState.Probe.update renderer

    # Position the update quad over the destination.
    size = 2 ** lightmapMipmapLevel
    halfSize = size / 2
    @lightmapQuad.position.x = lightmapCoordinates.x + halfSize
    @lightmapQuad.position.y = lightmapCoordinates.y + halfSize
    @lightmapQuad.scale.set size, size, size
    @lightmapQuad.updateWorldMatrix()

    @modelViewProjectionMatrix.copy(@lightmapQuad.matrixWorld).premultiply(lightmapCamera.projectionMatrix)

    # Transfer probe illumination to illumination in atlas.
    renderer.setRenderTarget lightmap

    if clear
      renderer.setClearColor 0, 0
      renderer.clearColor()

    renderer.render @lightmapScene, lightmapCamera

  constructor: (@mesh) ->
    lightmapSize = @mesh.lightmapAreaProperties.lightmapSize()

    @textureSize =
      width: lightmapSize.width
      height: lightmapSize.height

    # Create the atlas texture.
    @lightmap = new THREE.WebGLRenderTarget @textureSize.width, @textureSize.height,
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false
      generateMipmaps: true
      minFilter: THREE.LinearMipmapLinearFilter
      magFilter: THREE.LinearFilter

    # Create the probe maps atlas (which illumination probe should a certain pixel use).
    @lightmapAreas = new @constructor.LightmapAreas @mesh

    @cameraAngle = @mesh.cameraAngles.get 0

    @lightmapCamera = new THREE.OrthographicCamera 0, @textureSize.width, @textureSize.height, 0, 0.5, 1.5

  activeMipmapLevels: ->
    @lightmapAreas.activeMipmapLevels()

  destroy: ->
    @lightmap.dispose()

  update: (renderer, scene) ->
    return unless updatePixel = @lightmapAreas.getNewUpdatePixel()

    {cluster, pixelCoordinates, lightmapCoordinates, lightmapMipmapLevel} = updatePixel

    # Determine which cluster the pixel coordinates lie on.
    probeCubeCamera = LOI.Engine.RadianceState.Probe.cubeCamera
    probeCubeCamera.setRotationFromMatrix cluster.planeBasis

    # Place the camera on the spot on the cluster where we should render from.
    @cameraAngle.projectPoint pixelCoordinates, cluster.planeHelper, 0, 0, probeCubeCamera.position

    # Render the probe cube.
    renderer.setClearColor 0, 1
    probeCubeCamera.renderTarget.clear renderer
    probeCubeCamera.update renderer, scene

    # Update the illumination atlas.
    @constructor.updateLightmap renderer, lightmapCoordinates, lightmapMipmapLevel, @lightmap, @lightmapCamera, not @_performedInitialClear
    @_performedInitialClear = true
