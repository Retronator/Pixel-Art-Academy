AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.Skydome.RenderMaterial.Scattering extends LOI.Engine.Skydome.RenderMaterial
  constructor: (options) ->
    super _.extend
      fragmentShader: '#include <LandsOfIllusions.Engine.Skydome.RenderMaterial.Scattering.fragment>'
    ,
      options
