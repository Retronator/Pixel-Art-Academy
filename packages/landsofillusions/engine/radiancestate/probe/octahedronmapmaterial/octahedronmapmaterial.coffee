LOI = LandsOfIllusions

class LOI.Engine.RadianceState.Probe.OctahedronMapMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    parameters =
      blending: THREE.NoBlending

      uniforms:
        probeCube:
          value: LOI.Engine.RadianceState.Probe.cubeCamera.renderTarget.texture

      vertexShader: '#include <LandsOfIllusions.Engine.RadianceState.Probe.OctahedronMapMaterial.vertex>'
      fragmentShader: '#include <LandsOfIllusions.Engine.RadianceState.Probe.OctahedronMapMaterial.fragment>'

    super parameters
    @options = options
