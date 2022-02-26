AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Engine.Lightmap
  # How many levels deep to render the lightmap.
  @iterationsCount = 5
  
  # How many levels above the write level should the lightmap be used when drawing.
  @drawLevelDifference = 3
  
  # How steep the blending factor curve is (lower is slower blending).
  @blendingFactorBase = 0.4
  
  # Whether to progressively deepen the final write level across multiple iterations.
  @progressiveDeepening = true
  
  @initialize: ->
    # Prepare rendering the probe.
    @Probe.initialize()
    
    # Create a material that will overwrite the render target with initial data.
    @initializationMaterial = new THREE.MeshBasicMaterial
      blending: THREE.CustomBlending
      blendDst: THREE.ZeroFactor
      blendSrc: THREE.OneFactor

    @initializationQuad = new AS.ScreenQuad @initializationMaterial
  
    # Prepare rendering of the lightmap atlas.
    @modelViewProjectionMatrix = new THREE.Matrix4

    @updateMaterial = new @UpdateMaterial
      modelViewProjectionMatrix: @modelViewProjectionMatrix

    @lightmapQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(), @updateMaterial
    @lightmapQuad.position.z = -1

    @lightmapScene = new THREE.Scene()
    @lightmapScene.add @lightmapQuad
    
  @initializeLightmap: (renderer, renderTarget, initialTexture) ->
    @initializationMaterial.map = initialTexture
    @initializationMaterial.needsUpdate = true
    
    renderer.setRenderTarget renderTarget
    renderer.render @initializationQuad.scene, @initializationQuad.camera

  @updateLightmap: (renderer, coordinates, mipmapLevel, renderTarget, camera, blendFactor) ->
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
    
    # Update blend factor.
    unless @updateMaterial.uniforms.blendFactor.value is blendFactor
      @updateMaterial.uniforms.blendFactor.value = blendFactor
      @updateMaterial.needsUpdate = true

    # Transfer probe radiance to the lightmap.
    renderer.setRenderTarget renderTarget

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
    
    console.log "Created new lightmap.", @ if LOI.debug

  activeMipmapLevels: ->
    @areas.activeMipmapLevels()

  destroy: ->
    @renderTarget.dispose()
    @areas.destroy()

  update: (renderer, scene) ->
    unless @_initialized
      @constructor.initializeLightmap renderer, @renderTarget, @areas.initialTexture
      @_initialized = true
    
    # Report that there was nothing left to update.
    return false unless updatePixel = @areas.getNewUpdatePixel()

    {cluster, pixelCoordinates, lightmapCoordinates, lightmapMipmapLevel, iteration, level, blendFactor} = updatePixel

    # Determine which cluster the pixel coordinates lie on.
    probeCubeCamera = LOI.Engine.Lightmap.Probe.cubeCamera
    probeCubeCamera.setRotationFromMatrix cluster.planeBasis

    # Place the camera on the spot on the cluster where we should render from.
    @cameraAngle.projectPoint pixelCoordinates, cluster.planeHelper, 0, 0, probeCubeCamera.position

    # Render the probe cube.
    renderer.setClearColor 0, 1
    probeCubeCamera.renderTarget.clear renderer
    probeCubeCamera.update renderer, scene

    # Update the lightmap atlas. On the very first iteration we
    # don't want to do any blending so that the initial color gets set.
    if @constructor.progressiveDeepening
      blendFactor = 1 if iteration is 0 and not @_wasReset
      
    else
      blendFactor = 1 if level is 0 and not @_wasReset

    @constructor.updateLightmap renderer, lightmapCoordinates, lightmapMipmapLevel, @renderTarget, @updateCamera, blendFactor
    
    # Report that we've done an update.
    true

  resetActiveLevels: ->
    console.log "Resetting lightmap levels." if LOI.debug
    @areas.resetActiveLevels()
    @_wasReset = true

  completeness: ->
    @areas.completeness()
