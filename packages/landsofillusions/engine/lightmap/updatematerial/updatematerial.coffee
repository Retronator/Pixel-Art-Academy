LOI = LandsOfIllusions

class LOI.Engine.Lightmap.UpdateMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      glslVersion: THREE.GLSL3

      blending: THREE.NoBlending
      side: THREE.DoubleSide

      uniforms:
        modelViewProjectionMatrix:
          value: options.modelViewProjectionMatrix
        probeOctahedronMap:
          value: LOI.Engine.Lightmap.Probe.octahedronMap
        probeOctahedronMapMaxLevel:
          value: LOI.Engine.Lightmap.Probe.octahedronMapMaxLevel

      vertexShader: '#include <LandsOfIllusions.Engine.Lightmap.UpdateMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Lightmap.UpdateMaterial.fragment>'

    super parameters
    @options = options
