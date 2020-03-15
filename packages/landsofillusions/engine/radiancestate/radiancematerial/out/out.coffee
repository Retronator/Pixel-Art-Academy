LOI = LandsOfIllusions

class LOI.Engine.RadianceState.RadianceMaterial.Out extends LOI.Engine.RadianceState.RadianceMaterial
  constructor: (options) ->
    parameters =
      uniforms:
        # Material information
        refractiveIndex:
          value: new THREE.Vector3
        extinctionCoefficient:
          value: new THREE.Vector3
        emission:
          value: new THREE.Vector3

      fragmentShader: '#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.Out.fragment>'

    super parameters, options
    @options = options
