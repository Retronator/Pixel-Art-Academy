AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Shaders extends AR.Pages.Chemistry.Materials.Shaders
  onCreated: ->
    super arguments...

    # Create the scene.
    @scene = new THREE.Scene

    # Allow reactive updates of reflections when anything in the scene changes.
    @sceneUpdated = new Tracker.Dependency

    # Setup directional light.
    @directionalLight = new THREE.DirectionalLight
    @directionalLight.layers.mask = LOI.Engine.RenderLayerMasks.GeometricLight
    @sunColorMeasureSkydome = new LOI.Engine.Skydome.Procedural readColors: true

    # Reactively adjust directional light to match the environment.
    @autorun (computation) =>
      sunPosition = @sunPosition()
      @directionalLight.position.copy sunPosition

      sunDirection = sunPosition.clone().negate()
      @sunColorMeasureSkydome.updateTexture @renderer, sunDirection, @sunFactor(), 0

      @directionalLight.color.copy @sunColorMeasureSkydome.starColor
      @directionalLight.intensity = @sunColorMeasureSkydome.starLuminance * 2e-8

    # Directional light needs to be activated in the main procedural
    # environment and photo environments that have the sun directly visible.
    @autorun (computation) =>
      environmentName = @environmentName()

      if environmentName is 'Procedural' or @constructor.ProceduralSkySettings[environmentName]
        @scene.add @directionalLight

      else
        @scene.remove @directionalLight

    # Prepare for generating the environment map.
    @environmentMapGenerator = new THREE.PMREMGenerator @renderer

    # Generate the environment map from the sky texture.
    @skyTexture = new ReactiveField null

    @_environmentMapRenderTarget = null
    @environmentMap = new ComputedField =>
      return unless skyTexture = @skyTexture()

      @_environmentMapRenderTarget?.dispose()
      @_environmentMapRenderTarget = @environmentMapGenerator.fromCubemap skyTexture
      @_environmentMapRenderTarget.texture

    # Create the skydome and render the sky texture.
    @autorun (computation) =>
      environmentUrl = @environmentUrl()
      @scene.remove @skydome if @skydome

      if @environmentIsProcedural()
        # In the indirect-only procedural sky we want to render a bigger sun to make the lighting
        # more stable since the environment map generated with PMREMGenerator is quite low resolution.
        indirectOnly = environmentUrl is 'ProceduralIndirect'
        sunScale = if indirectOnly then 5 else 1
        sunAreaFactor = sunScale ** 2

        starFactor = @sunFactor() / sunAreaFactor
        scatteringFactor = @skyFactor()

        # Create the procedural skydome in case the previous one was a photo.
        unless @skydome instanceof LOI.Engine.Skydome.Procedural
          @skydome = new LOI.Engine.Skydome.Procedural
            resolution: 4096
            star:
              angularSize: 0.00931 * sunScale
            generateCubeTexture: true

        # Render the procedural sky.
        direction = @sunPosition().clone().multiplyScalar -1
        @skydome.updateTexture @renderer, direction, starFactor, scatteringFactor

        # Set the sky texture to trigger generation of the environment map.
        @skyTexture @skydome.cubeTexture

      else
        # Load the photo environment.
        @skydome = new LOI.Engine.Skydome.Photo
          generateCubeTexture: true
          onLoaded: =>
            # Render cube texture.
            @skydome.updateTexture @renderer
            @renderer.setRenderTarget null

            # Set the sky texture to trigger generation of the environment map.
            @skyTexture @skydome.cubeTexture

        @skydome.loadFromUrl environmentUrl

      # Add the new skydome to the scene.
      @scene.add @skydome

    # For scenes that have a directly visible sun we want to block it during environment map generation
    # so we only get indirect lighting contribution (the direct one will come from the direct light).
    sunBlockerGeometry = new THREE.SphereGeometry 25
    @sunBlockerMaterial = new THREE.MeshBasicMaterial color: 0
    @sunBlocker = new THREE.Mesh sunBlockerGeometry, @sunBlockerMaterial
    @sunBlocker.layers.set LOI.Engine.RenderLayers.Indirect
    @sunBlocker.visible = false
    @scene.add @sunBlocker

    @autorun (computation) =>
      @sunBlocker.position.copy(@sunPosition()).multiplyScalar 950

    # Create the 5 preview spheres.
    @sphereRadius = 0.25
    material = new THREE.MeshBasicMaterial color: 0xffffff

    @spheres = for i in [-2..2]
      sphereGeometry = new THREE.SphereGeometry @sphereRadius, 64, 32

      materialPropertiesIndices = new Uint8Array sphereGeometry.attributes.position.count
      maxUint8Value = 255
      stretchFactor = maxUint8Value / (LOI.Engine.Textures.MaterialProperties.maxItems - 1)
      materialPropertiesIndices.fill (i + 2) * stretchFactor

      sphereGeometry.setAttribute 'materialPropertiesIndex', new THREE.BufferAttribute materialPropertiesIndices, 1, true

      sphere = new THREE.Mesh sphereGeometry, material
      sphere.layers.mask = LOI.Engine.RenderLayerMasks.NonEmissive
      sphere.position.z = i
      @scene.add sphere
      sphere
