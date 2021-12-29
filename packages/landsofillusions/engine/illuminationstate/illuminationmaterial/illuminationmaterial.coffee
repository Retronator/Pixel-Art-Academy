LOI = LandsOfIllusions

class LOI.Engine.IlluminationState.IlluminationMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.NoBlending
      side: THREE.DoubleSide

      uniforms:
        modelViewProjectionMatrix:
          value: options.modelViewProjectionMatrix
        probeOctahedronMap:
          value: LOI.Engine.RadianceState.Probe.octahedronMap
        probeOctahedronMapMaxLevel:
          value: LOI.Engine.RadianceState.Probe.octahedronMapMaxLevel
        probeOctahedronMapResolution:
          value: LOI.Engine.RadianceState.Probe.octahedronMapResolution

      vertexShader: '#include <LandsOfIllusions.Engine.IlluminationState.IlluminationMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.IlluminationState.IlluminationMaterial.fragment>'

    super parameters
    @options = options
