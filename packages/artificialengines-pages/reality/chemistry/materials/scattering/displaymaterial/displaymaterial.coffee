AR = Artificial.Reality

class AR.Pages.Chemistry.Materials.Scattering.DisplayMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.NormalBlending

      uniforms: _.extend
        surfaceSDFTexture:
          value: options.surfaceSDFTexture
        rayScatteringDataTexture:
          value: options.rayScatteringDataTexture
        lightTexture:
          value: options.lightTexture
        schematicView:
          value: false
        toneMappingExposure:
          value: 1
      ,
        options.uniforms

      vertexShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.DisplayMaterial.vertex>'
      fragmentShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.DisplayMaterial.fragment>'

    super parameters
    @options = options
