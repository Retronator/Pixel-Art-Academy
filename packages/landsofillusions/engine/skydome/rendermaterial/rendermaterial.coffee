LOI = LandsOfIllusions

class LOI.Engine.Skydome.RenderMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.NoBlending

      uniforms:
        sunDirection:
          value: new THREE.Vector3 0, -1, 0

      vertexShader: '#include <LandsOfIllusions.Engine.Skydome.RenderMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Skydome.RenderMaterial.fragment>'

    super parameters
    @options = options
