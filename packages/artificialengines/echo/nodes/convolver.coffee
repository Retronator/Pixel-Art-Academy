AEc = Artificial.Echo

class AEc.Node.Convolver extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Convolver'
  @displayName: -> 'Convolver'

  @initialize()

  @inputs: -> [
    name: 'in'
    type: AEc.ConnectionTypes.Channels
  ]

  @outputs: -> [
    name: 'out'
    type: AEc.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'buffer'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Buffer
  ,
    name: 'normalize'
    pattern: Match.OptionalOrNull Boolean
    default: true
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Boolean
  ]

  constructor: ->
    super arguments...

    @node = new ConvolverNode @audio.context
    
    @autorun (computation) =>
      @node.buffer = @readParameter 'buffer'

    @autorun (computation) =>
      @node.normalize = @readParameter 'normalize'
    
  getDestinationConnection: (input) ->
    empty = super arguments...

    switch input
      when 'in'
        destination: @node

      else
        empty

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node
