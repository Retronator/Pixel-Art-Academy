LOI = LandsOfIllusions

class LOI.Engine.RadianceState.RadianceMaterial extends THREE.RawShaderMaterial
  constructor: (parameters, options) ->
    _.merge parameters,
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
        radianceAtlasProbeLevel:
          value: LOI.Engine.RadianceState.radianceAtlasProbeLevel
        radianceAtlasProbeResolution:
          value: LOI.Engine.RadianceState.radianceAtlasProbeResolution

      vertexShader: '#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.vertex>'

    super parameters
    @options = options
