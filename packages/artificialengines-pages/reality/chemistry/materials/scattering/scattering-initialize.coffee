AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Scattering extends AR.Pages.Chemistry.Materials.Scattering
  @register 'Artificial.Reality.Pages.Chemistry.Materials.Scattering'

  _initialize: ->
    # Create rendering objects.
    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'

    @renderer.autoClear = false

    @camera = new THREE.Camera
    @accumulatedExposure = 0

    # Initialize sub-systems.
    @_initializeSurface()
    @_initializeResources()
    @_initializeRayProperties()

    # Create and update the light ray.
    @lightRay = new ComputedField =>
      return unless surfaceHelpers = @surfaceHelpers()
      return unless direction = @lightRayDirection()?.clone()

      origin = direction.clone().multiplyScalar(-surfaceHelpers.rayIntersectionDistance).add(surfaceHelpers.rayTarget)
      new THREE.Ray origin, direction

    # Resize renderer when surface changes.
    @autorun (computation) =>
      return unless size = @size()
      @renderer.setSize size.width, size.height

    # Update schematic view mode.
    @autorun (computation) =>
      return unless resources = @resources()
      schematicView = @schematicView()

      resources.rayMaterial.uniforms.schematicView.value = schematicView
      resources.rayMaterial.needsUpdate = true

      resources.displayMaterial.uniforms.schematicView.value = schematicView
      resources.displayMaterial.needsUpdate = true

    # Restart rendering when relevant properties change.
    @autorun (computation) =>
      return unless resources = @resources()

      # Depend on ray property changes.
      @rayPropertiesDependency.depend()

      # Depend on light ray.
      @lightRay()
      @beamWidth()

      # Depend on schematic view.
      @schematicView()

      # Clear render target.
      @renderer.setRenderTarget resources.lightRenderTarget
      @renderer.setClearColor 0, 1
      @renderer.clear()

      @accumulatedExposure = 0
