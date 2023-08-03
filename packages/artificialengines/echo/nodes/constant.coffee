AEc = Artificial.Echo

class AEc.Node.Constant extends AEc.Node.ScheduledNode
  @type: -> 'Artificial.Echo.Node.Constant'
  @displayName: -> 'Constant'

  @initialize()

  @parameters: ->
    super(arguments...).concat
      name: 'offset'
      pattern: Match.OptionalOrNull Number
      default: 1
      step: 0.1
      type: AEc.ConnectionTypes.Parameter

  createSource: (context) ->
    new ConstantSourceNode context
