AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Skydome.Photo extends LOI.Engine.Skydome
  constructor: (options = {}) ->
    super arguments...

    @loader = new THREE.RGBELoader()
    @loader.setDataType THREE.FloatType

    # A photo skydome is used both in the final render and to render indirect lights (even though it can include direct
    # lights, but we assume these will not be replicated with geometric lights, so it's OK that they are there).
    @sphere.layers.enable LOI.Engine.RenderLayers.Indirect

    # We rotate the sphere so the cube map directions will match the scene when applied as an environment map.
    @cubeSceneSphere.rotation.y = Math.PI / 2

  createMaterial: -> new @constructor.Material

  loadFromUrl: (url) ->
    # Temporarily hide the sphere until the map is loaded.
    sphereWasVisible = @sphere.visible
    @sphere.visible = false

    @loader.load url, (texture) =>
      @material.map?.dispose()

      @material.map = texture
      @material.uniforms.map.value = texture
      @material.needsUpdate = true

      if @options.generateCubeTexture or @options.generateEnvironmentMap
        @cubeSceneSphereMaterial.map = texture
        @cubeSceneSphereMaterial.uniforms.map.value = texture
        @cubeSceneSphereMaterial.needsUpdate = true

      @sphere.visible = sphereWasVisible

      @options.onLoaded?()
