LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Constant extends LOI.Assets.Engine.Audio.ScheduledNode
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.Constant'
  @nodeName: -> 'Constant'

  @initialize()

  @parameters: ->
    super(arguments...).concat
      name: 'offset'
      pattern: Match.OptionalOrNull Number
      default: 1
      step: 0.1
      type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter

  createSource: (context) ->
    context.createConstantSource()

  updateSources: (sources) ->
    offset = @readParameter 'offset'

    for source in sources
      source.offset.value = offset
