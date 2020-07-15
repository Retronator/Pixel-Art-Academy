AR = Artificial.Reality

class AR.Pages.Chemistry.Materials.Scattering.RayMarchingMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.NormalBlending

      uniforms: _.extend
        rayScatteringDataTexture:
          value: options.rayScatteringDataTexture
        surfaceSDFTexture:
          value: options.surfaceSDFTexture
        rayPropertiesTexture:
          value: options.rayPropertiesTexture
        updateLevel:
          value: options.updateLevel
      ,
        options.uniforms

      vertexShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMarchingMaterial.vertex>'
      fragmentShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMarchingMaterial.fragment>'

    super parameters
    @options = options

    @map = options.map
    @needsUpdate = true
