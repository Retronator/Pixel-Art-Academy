AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.Skydome.Procedural.RenderMaterial.Scattering extends LOI.Engine.Skydome.Procedural.RenderMaterial
  constructor: (options) ->
    super _.extend
      fragmentShader: '#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.Scattering.fragment>'
    ,
      options
