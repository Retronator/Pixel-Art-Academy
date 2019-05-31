LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Hair extends LOI.Character.Avatar.Renderers.Default
  _getSortedRenderers: (options) ->
    _.sortBy @renderers()
    ,
      (renderer) =>
        switch renderer.options.part.properties.region.options.dataLocation()
          when 'HairBehind' then 0
          when 'HairMiddle' then 1
          when 'HairFront' then 2
    ,
      (renderer) =>
        renderer._depth[options.side]
