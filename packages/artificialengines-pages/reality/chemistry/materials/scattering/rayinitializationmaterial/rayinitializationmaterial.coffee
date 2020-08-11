AR = Artificial.Reality

class AR.Pages.Chemistry.Materials.Scattering.RayInitializationMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.NoBlending

      uniforms: _.extend
        map:
          value: options.map
      ,
        options.uniforms

      vertexShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayInitializationMaterial.vertex>'
      fragmentShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayInitializationMaterial.fragment>'

    super parameters
    @options = options

    @map = options.map
    @needsUpdate = true
