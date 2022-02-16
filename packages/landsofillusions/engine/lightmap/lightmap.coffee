LOI = LandsOfIllusions

class LOI.Engine.Lightmap
  @initialize: ->
    # Prepare rendering the probe.
    @Probe.initialize()

    # Prepare rendering of the lightmap atlas.
    @modelViewProjectionMatrix = new THREE.Matrix4

    @updateMaterial = new @UpdateMaterial
      modelViewProjectionMatrix: @modelViewProjectionMatrix

    @lightmapQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(), @updateMaterial
    @lightmapQuad.position.z = -1

    @lightmapScene = new THREE.Scene()
    @lightmapScene.add @lightmapQuad

  @updateLightmap: (renderer, coordinates, mipmapLevel, renderTarget, camera, clear) ->
    # Update probe map.
    LOI.Engine.Lightmap.Probe.update renderer

    # Position the update quad over the destination.
    size = 2 ** mipmapLevel
    halfSize = size / 2
    @lightmapQuad.position.x = coordinates.x + halfSize
    @lightmapQuad.position.y = coordinates.y + halfSize
    @lightmapQuad.scale.set size, size, size
    @lightmapQuad.updateWorldMatrix()

    @modelViewProjectionMatrix.copy(@lightmapQuad.matrixWorld).premultiply camera.projectionMatrix

    # Transfer probe radiance to the lightmap.
    renderer.setRenderTarget renderTarget

    if clear
      renderer.setClearColor 0, 0
      renderer.clearColor()

    renderer.render @lightmapScene, camera

  constructor: (@mesh) ->
    lightmapSize = @mesh.lightmapAreaProperties.lightmapSize()

    @textureSize =
      width: lightmapSize.width
      height: lightmapSize.height

    # Create the atlas texture.
    @renderTarget = new THREE.WebGLRenderTarget @textureSize.width, @textureSize.height,
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false
      generateMipmaps: true
      minFilter: THREE.LinearMipmapLinearFilter
      magFilter: THREE.LinearFilter

    @texture = @renderTarget.texture

    # Create the probe maps atlas (which lightmap probe should a certain pixel use).
    @areas = new @constructor.Areas @mesh

    @cameraAngle = @mesh.cameraAngles.get 0

    @updateCamera = new THREE.OrthographicCamera 0, @textureSize.width, @textureSize.height, 0, 0.5, 1.5
    @updateCamera.layers.set LOI.Engine.RenderLayers.Indirect

  activeMipmapLevels: ->
    @areas.activeMipmapLevels()

  destroy: ->
    @renderTarget.dispose()

  update: (renderer, scene) ->
    return unless updatePixel = @areas.getNewUpdatePixel()

    {cluster, pixelCoordinates, lightmapCoordinates, lightmapMipmapLevel} = updatePixel

    # Determine which cluster the pixel coordinates lie on.
    probeCubeCamera = LOI.Engine.Lightmap.Probe.cubeCamera
    probeCubeCamera.setRotationFromMatrix cluster.planeBasis

    # Place the camera on the spot on the cluster where we should render from.
    @cameraAngle.projectPoint pixelCoordinates, cluster.planeHelper, 0, 0, probeCubeCamera.position

    # Render the probe cube.
    renderer.setClearColor 0, 1
    probeCubeCamera.renderTarget.clear renderer
    probeCubeCamera.update renderer, scene

    # Update the lightmap atlas.
    @constructor.updateLightmap renderer, lightmapCoordinates, lightmapMipmapLevel, @renderTarget, @updateCamera, not @_performedInitialClear
    @_performedInitialClear = true
