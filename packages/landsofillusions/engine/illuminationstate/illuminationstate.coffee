LOI = LandsOfIllusions

class LOI.Engine.IlluminationState
  @initialize: ->
    # Prepare rendering of illumination atlases.
    @modelViewProjectionMatrix = new THREE.Matrix4

    @illuminationMaterial = new @IlluminationMaterial
      modelViewProjectionMatrix: @modelViewProjectionMatrix

    @illuminationAtlasQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(), @illuminationMaterial
    @illuminationAtlasQuad.position.z = -1

    @illuminationAtlasScene = new THREE.Scene()
    @illuminationAtlasScene.add @illuminationAtlasQuad

  @updateIlluminationAtlas: (renderer, atlasCoordinates, illuminationAtlas, illuminationAtlasCamera, clear) ->
    # Update probe map.
    LOI.Engine.RadianceState.Probe.update renderer

    # Position the update quad over the destination.
    @illuminationAtlasQuad.position.x = atlasCoordinates.x + 0.5
    @illuminationAtlasQuad.position.y = atlasCoordinates.y + 0.5
    @illuminationAtlasQuad.updateWorldMatrix()

    @modelViewProjectionMatrix.copy(@illuminationAtlasQuad.matrixWorld).premultiply(illuminationAtlasCamera.projectionMatrix)

    # Transfer probe illumination to illumination in atlas.
    renderer.setRenderTarget illuminationAtlas

    if clear
      renderer.setClearColor 0, 0
      renderer.clearColor()

    renderer.render @illuminationAtlasScene, illuminationAtlasCamera

  constructor: (@mesh) ->
    layerAtlasSize = @mesh.layerProperties.layerAtlasSize()

    @textureSize =
      width: layerAtlasSize.width
      height: layerAtlasSize.height

    # Create the atlas texture.
    @illuminationAtlas = new THREE.WebGLRenderTarget @textureSize.width, @textureSize.height,
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false
      #minFilter: THREE.NearestFilter
      #magFilter: THREE.NearestFilter

    # Create the probe maps atlas (which illumination probe should a certain pixel use).
    @probeMapAtlas = new @constructor.ProbeMapAtlas @mesh

    @cameraAngle = @mesh.cameraAngles.get 0

    @illuminationAtlasCamera = new THREE.OrthographicCamera 0, @textureSize.width, @textureSize.height, 0, 0.5, 1.5

  destroy: ->
    @illuminationAtlas.dispose()

  update: (renderer, scene) ->
    return unless updatePixel = @probeMapAtlas.getNewUpdatePixel()

    {cluster, pixelCoordinates, atlasCoordinates} = updatePixel

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
    @constructor.updateIlluminationAtlas renderer, atlasCoordinates, @illuminationAtlas, @illuminationAtlasCamera, not @_performedInitialClear
    @_performedInitialClear = true
