AEc = Artificial.Echo

class AEc.Node.StereoPanner extends AEc.Node
  @type: -> 'Artificial.Echo.Node.StereoPanner'
  @displayName: -> 'Stereo Panner'

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
    name: 'pan'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    min: -1
    max: 1
    type: AEc.ConnectionTypes.Parameter
  ]

  constructor: ->
    super arguments...

    @node = new StereoPannerNode @audio.context

    @autorun (computation) =>
      @node.pan.value = @readParameter 'pan'
    
  getDestinationConnection: (input) ->
    empty = super arguments...

    switch input
      when 'in'
        destination: @node

      when 'pan'
        destination: @node.pan

      else
        empty

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node
