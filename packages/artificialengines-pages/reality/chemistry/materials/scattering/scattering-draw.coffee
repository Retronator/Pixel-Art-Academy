AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Scattering extends AR.Pages.Chemistry.Materials.Scattering
  draw: ->
    return unless resources = @resources()
    return unless lightRay = @lightRay()
    return unless surfaceHelpers = @surfaceHelpers()

    # Initialize rays based on direction.
    raysCount = @raysCount()
    beamWidth = @beamWidth()
    schematicView = @schematicView()
    schematicRaysCount = Math.floor(beamWidth / 10)

    randomRay = lightRay.clone()
    randomOrigin = new THREE.Vector3

    for rayIndex in [0...raysCount]
      pixelOffset = rayIndex * 4

      # Set ray position (x, y).
      if schematicView
        # We use thickness offset to draw lines 2px thick.
        thicknessOffset = Math.floor(rayIndex / schematicRaysCount) % 2
        beamOffset = (rayIndex % schematicRaysCount) / schematicRaysCount + thicknessOffset / beamWidth

      else
        beamOffset = Math.random()

      beamOffset = (beamOffset - 0.5) * beamWidth
      randomRay.origin.x = lightRay.origin.x + lightRay.direction.y * beamOffset
      randomRay.origin.y = lightRay.origin.y - lightRay.direction.x * beamOffset
      randomRay.intersectBox surfaceHelpers.canvasBox, randomOrigin

      resources.initialRayScatteringData[pixelOffset] = randomOrigin.x
      resources.initialRayScatteringData[pixelOffset + 1] = randomOrigin.y

      # Set ray direction (x, y).
      resources.initialRayScatteringData[pixelOffset + 2] = lightRay.direction.x
      resources.initialRayScatteringData[pixelOffset + 3] = lightRay.direction.y

    resources.initialRayScatteringDataTexture.needsUpdate = true

    for i in [0..1]
      @renderer.setRenderTarget resources.rayScatteringDataRenderTargets[i]
      @renderer.render resources.rayInitializationScene, @camera

    # March and split the rays.
    for updateLevel in [0...resources.segmentLevelsPerRay]
      # Level zero has just the incoming ray so no splitting is necessary.
      if updateLevel > 0
        # Split each ray into reflection and refraction.
        resources.raySplittingMaterial.uniforms.updateLevel.value = updateLevel
        resources.raySplittingMaterial.needsUpdate = true

        @renderer.setRenderTarget resources.rayScatteringDataRenderTargets[0]
        @renderer.render resources.raySplittingScene, @camera

      # March each ray to surface boundary.
      resources.rayMarchingMaterial.uniforms.updateLevel.value = updateLevel
      resources.rayMarchingMaterial.needsUpdate = true

      @renderer.setRenderTarget resources.rayScatteringDataRenderTargets[1]
      @renderer.render resources.rayMarchingScene, @camera

    # Render light rays to render target.
    @renderer.setRenderTarget resources.lightRenderTarget
    @renderer.render resources.raysScene, @camera

    # Correct exposure
    @accumulatedExposure++
    exposureValue = @exposureValue()
    exposureValue -= 7 if schematicView
    resources.displayMaterial.uniforms.toneMappingExposure.value = (2 ** exposureValue) / @accumulatedExposure * 1024 / raysCount
    resources.displayMaterial.needsUpdate = true

    # Display the final result.
    @renderer.setRenderTarget null
    @renderer.setClearColor 0, 0
    @renderer.clear()
    @renderer.render resources.displayScene, @camera
