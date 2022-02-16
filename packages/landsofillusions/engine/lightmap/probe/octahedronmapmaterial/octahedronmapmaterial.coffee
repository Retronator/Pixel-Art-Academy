LOI = LandsOfIllusions

class LOI.Engine.Lightmap.Probe.OctahedronMapMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    samplesPerHemisphere = LOI.Engine.Lightmap.Probe.octahedronMapResolution ** 2
    hemisphereSolidAngle = 2 * Math.PI
    sampleSolidAngle = hemisphereSolidAngle / samplesPerHemisphere

    parameters =
      blending: THREE.NoBlending

      uniforms:
        probeCube:
          value: LOI.Engine.Lightmap.Probe.cubeCamera.renderTarget.texture
        sampleSolidAngle:
          value: sampleSolidAngle

      vertexShader: '#include <LandsOfIllusions.Engine.Lightmap.Probe.OctahedronMapMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.Lightmap.Probe.OctahedronMapMaterial.fragment>'

    super parameters
    @options = options
