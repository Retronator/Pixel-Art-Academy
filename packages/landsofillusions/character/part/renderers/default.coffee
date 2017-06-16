LOI = LandsOfIllusions

# This is a default renderer that simply renders all the parts found in the properties.
class LOI.Character.Part.Renderers.Default
  constructor: (@engineOptions, @rendererOptions) ->
    @renderers = new ComputedField =>
      renderers = []

      for property in @rendererOptions.part.properties
        if property instanceof LOI.Character.Part.Property.OneOf
          renderers.push property.part.createRenderer @engineOptions

      renderers

  drawToContext: (context) ->
    for renderer in @renderers()
      renderer.drawToContext context
