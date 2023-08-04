AEc = Artificial.Echo

class AEc.Node.Mixer extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Mixer'
  @displayName: -> 'Mixer'

  @initialize()
  
  @channelsCount = 5
  
  @inputs: -> for channelNumber in [1..@channelsCount]
    name: channelNumber.toString()
    type: AEc.ConnectionTypes.Channels
  
  @outputs: -> [
    name: 'out'
    type: AEc.ConnectionTypes.Channels
  ]
  
  @parameters: ->
    parameters = for channelNumber in [1..@channelsCount]
      name: "gain#{channelNumber}"
      pattern: Match.OptionalOrNull Number
      step: 0.1
      default: 1
      type: AEc.ConnectionTypes.Parameter
      
    parameters.unshift
      name: 'name'
      pattern: String
      type: AEc.ConnectionTypes.ReactiveValue
      valueType: Match.OptionalOrNull AEc.ValueTypes.String
    
    parameters
    
  @_outputNodes = {}
  
  @_getOutputNodeForName: (name, context) ->
    @_outputNodes[name] ?= new GainNode context
    @_outputNodes[name]
  
  constructor: ->
    super arguments...
    
    @inputNodes = (new GainNode @audio.context for channelNumber in [1..@constructor.channelsCount])
    
    # Reactive rewire input nodes to the named output node.
    @outputNode = new ReactiveField null
    
    @autorun (computation) =>
      if outputNode = Tracker.nonreactive => @outputNode()
        for inputNode in @inputNodes
          inputNode.disconnect outputNode
      
      # If we have a name, we want the global output node with that name so we can wire across audio documents.
      if name = @readParameter 'name'
        outputNode = @constructor._getOutputNodeForName name, @audio.context
        
      else
        # Otherwise we want a local (anonymous) mixer node that just works inside the document.
        outputNode = new GainNode @audio.context
      
      for inputNode in @inputNodes
        inputNode.connect outputNode
        
      @outputNode outputNode
      
    # Update gain on the inputs.
    for channelNumber in [1..@constructor.channelsCount]
      do (channelNumber) =>
        @autorun (computation) =>
          @inputNodes[channelNumber - 1].gain.value = @readParameter "gain#{channelNumber}"
        
  getDestinationConnection: (input) ->
    empty = super arguments...
    
    channelNumber = parseInt(input)
    return empty if _.isNaN channelNumber
    
    if 1 <= channelNumber <= @constructor.channelsCount
      destination: @inputNodes[channelNumber - 1]
      
    else
      empty
  
  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'
    
    source: @outputNode()
