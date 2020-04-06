LOI = LandsOfIllusions

class LOI.Engine.RadianceState.Probe.OctahedronMapMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    samplesPerHemisphere = LOI.Engine.RadianceState.Probe.octahedronMapResolution ** 2
    hemisphereSolidAngle = 2 * Math.PI
    sampleSolidAngle = hemisphereSolidAngle / samplesPerHemisphere

    parameters =
      blending: THREE.NoBlending

      uniforms:
        probeCube:
          value: LOI.Engine.RadianceState.Probe.cubeCamera.renderTarget.texture
        sampleSolidAngle:
          value: sampleSolidAngle

      vertexShader: '#include <LandsOfIllusions.Engine.RadianceState.Probe.OctahedronMapMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.RadianceState.Probe.OctahedronMapMaterial.fragment>'

    super parameters
    @options = options
