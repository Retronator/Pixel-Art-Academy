AR = Artificial.Reality

class AR.Pages.Chemistry.Materials.Scattering.RayMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.AdditiveBlending

      uniforms: _.extend
        pixelUnitSize:
          value: options.pixelUnitSize
        rayScatteringDataTexture:
          value: options.rayScatteringDataTexture
        rayPropertiesTexture:
          value: options.rayPropertiesTexture
        schematicView:
          value: false
      ,
        options.uniforms

      vertexShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMaterial.vertex>'
      fragmentShader: '#include <Artificial.Reality.Pages.Chemistry.Materials.Scattering.RayMaterial.fragment>'

    super parameters
    @options = options
