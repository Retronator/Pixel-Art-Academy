LOI = LandsOfIllusions

class LOI.Engine.RadianceState.RadianceMaterial.Out extends LOI.Engine.RadianceState.RadianceMaterial
  constructor: (options) ->
    parameters =
      fragmentShader: '#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.Out.fragment>'

    super parameters, options
    @options = options
