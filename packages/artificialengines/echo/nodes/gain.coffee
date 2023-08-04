AEc = Artificial.Echo

class AEc.Node.Gain extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Gain'
  @displayName: -> 'Gain'

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
    name: 'gain'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    type: AEc.ConnectionTypes.Parameter
  ]

  constructor: ->
    super arguments...

    @node = new GainNode @audio.context

    @autorun (computation) =>
      @node.gain.value = @readParameter 'gain'
    
  getDestinationConnection: (input) ->
    empty = super arguments...

    switch input
      when 'in'
        destination: @node

      when 'gain'
        destination: @node.gain

      else
        empty

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node
