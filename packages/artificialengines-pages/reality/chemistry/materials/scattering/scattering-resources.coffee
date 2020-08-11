AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Scattering extends AR.Pages.Chemistry.Materials.Scattering
  _initializeResources: ->
    # Automatically create and update rendering resources.
    _resources = rayScatteringDataRenderTargets: []

    @resources = new ComputedField =>
      raysCount = @raysCount()
      scatteringEventsCount = @scatteringEventsCount()
      return unless surfaceSDFTexture = @surfaceSDFTexture()
      return unless size = @size()

      _resources.segmentLevelsPerRay = scatteringEventsCount + 1
      verticesPerRay = 2 ** _resources.segmentLevelsPerRay
      segmentsPerRay = verticesPerRay - 1

      _resources.uniforms =
        canvasSize: value: new THREE.Vector2 size.width, size.height
        minTransmission: value: 1e-9
        raysCount: value: raysCount
        verticesPerRay: value: verticesPerRay

      for i in [0..1]
        _resources.rayScatteringDataRenderTargets[i]?.dispose()
        _resources.rayScatteringDataRenderTargets[i] = new THREE.WebGLRenderTarget raysCount * 2, verticesPerRay,
          type: THREE.FloatType
          stencilBuffer: false
          depthBuffer: false
          minFilter: THREE.NearestFilter
          magFilter: THREE.NearestFilter

      # Prepare initialization of ray scattering data.
      _resources.initialRayScatteringData = new Float32Array raysCount * 4

      _resources.initialRayScatteringDataTexture?.dispose()
      _resources.initialRayScatteringDataTexture = new THREE.DataTexture _resources.initialRayScatteringData, raysCount, 1
      _resources.initialRayScatteringDataTexture.type = THREE.FloatType

      _resources.rayInitializationMaterial?.dispose()
      _resources.rayInitializationMaterial = new @constructor.RayInitializationMaterial
        map: _resources.initialRayScatteringDataTexture
        uniforms: _resources.uniforms

      _resources.rayInitializationScene?.dispose()
      _resources.rayInitializationScene = new THREE.Scene()
      _resources.rayInitializationScene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), _resources.rayInitializationMaterial

      # Create ray properties texture.
      _resources.rayPropertiesData = new Float32Array raysCount * 8
      _resources.rayPropertiesDataTexture?.dispose()
      _resources.rayPropertiesDataTexture = new THREE.DataTexture _resources.rayPropertiesData, raysCount * 2, 1
      _resources.rayPropertiesDataTexture.type = THREE.FloatType

      # Prepare for ray marching.
      _resources.rayMarchingMaterial?.dispose()
      _resources.rayMarchingMaterial = new @constructor.RayMarchingMaterial
        rayScatteringDataTexture: _resources.rayScatteringDataRenderTargets[0].texture
        surfaceSDFTexture: surfaceSDFTexture
        rayPropertiesTexture: _resources.rayPropertiesDataTexture
        updateLevel: 0
        uniforms: _resources.uniforms

      _resources.rayMarchingScene?.dispose()
      _resources.rayMarchingScene = new THREE.Scene()
      _resources.rayMarchingScene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), _resources.rayMarchingMaterial

      # Prepare for ray splitting.
      _resources.raySplittingMaterial?.dispose()
      _resources.raySplittingMaterial = new @constructor.RaySplittingMaterial
        rayScatteringDataTexture: _resources.rayScatteringDataRenderTargets[1].texture
        surfaceSDFTexture: surfaceSDFTexture
        rayPropertiesTexture: _resources.rayPropertiesDataTexture
        updateLevel: 1
        uniforms: _resources.uniforms

      _resources.raySplittingScene?.dispose()
      _resources.raySplittingScene = new THREE.Scene()
      _resources.raySplittingScene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), _resources.raySplittingMaterial

      # Prepare ray lines for rendering.
      _resources.raysGeometry?.dispose()
      _resources.raysGeometry = new THREE.BufferGeometry()

      vertexCount = segmentsPerRay * 2 * raysCount
      rayIds = new Float32Array vertexCount
      segmentIds = new Float32Array vertexCount
      segmentDistances = new Float32Array vertexCount

      for rayId in [0...raysCount]
        for segmentIndex in [0...segmentsPerRay]
          vertexOffset = (segmentIndex + rayId * segmentsPerRay) * 2

          segmentId = segmentIndex + 1

          rayIds[vertexOffset] = rayId
          segmentIds[vertexOffset] = segmentId
          segmentDistances[vertexOffset] = 0

          rayIds[vertexOffset + 1] = rayId
          segmentIds[vertexOffset + 1] = segmentId
          segmentDistances[vertexOffset + 1] = 1

      _resources.raysGeometry.setAttribute 'rayId', new THREE.BufferAttribute rayIds, 1
      _resources.raysGeometry.setAttribute 'segmentId', new THREE.BufferAttribute segmentIds, 1
      _resources.raysGeometry.setAttribute 'segmentDistance', new THREE.BufferAttribute segmentDistances, 1

      # HACK: Also add position attribute, even though we don't need it, since otherwise
      # nothing renders. Can't figure out why from inspecting the three.js source code.
      _resources.raysGeometry.setAttribute 'position', new THREE.BufferAttribute new Float32Array(vertexCount * 3), 3

      _resources.rayMaterial?.dispose()
      _resources.rayMaterial = new @constructor.RayMaterial
        pixelUnitSize: 1e-6 # 1µm
        rayScatteringDataTexture: _resources.rayScatteringDataRenderTargets[1].texture
        rayPropertiesTexture: _resources.rayPropertiesDataTexture
        uniforms: _resources.uniforms

      _resources.raysLineSegments = new THREE.LineSegments _resources.raysGeometry, _resources.rayMaterial

      _resources.raysScene = new THREE.Scene()
      _resources.raysScene.add _resources.raysLineSegments

      # Prepare light render target.
      _resources.lightRenderTarget?.dispose()
      _resources.lightRenderTarget = new THREE.WebGLRenderTarget size.width, size.height,
        type: THREE.FloatType
        stencilBuffer: false
        depthBuffer: false

      # Create final display.
      _resources.displayMaterial?.dispose()
      _resources.displayMaterial = new @constructor.DisplayMaterial
        surfaceSDFTexture: surfaceSDFTexture
        rayScatteringDataTexture: _resources.rayScatteringDataRenderTargets[1].texture
        lightTexture: _resources.lightRenderTarget.texture
        uniforms: _resources.uniforms

      _resources.displayScene?.dispose()
      _resources.displayScene = new THREE.Scene()
      _resources.displayScene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), _resources.displayMaterial

      _resources
