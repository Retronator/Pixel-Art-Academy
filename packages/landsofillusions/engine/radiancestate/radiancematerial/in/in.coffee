LOI = LandsOfIllusions

class LOI.Engine.RadianceState.RadianceMaterial.In extends LOI.Engine.RadianceState.RadianceMaterial
  constructor: (options) ->
    parameters =
      fragmentShader: '#include <LandsOfIllusions.Engine.RadianceState.RadianceMaterial.In.fragment>'

    super parameters, options
    @options = options
