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
      name: "masterGain"
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
  
  @getOutputNodeForName: (name, context) ->
    @_outputNodes[name] ?= new GainNode context
    @_outputNodes[name]
  
  constructor: ->
    super arguments...
    
    @masterGainNode = new GainNode @audio.context
    
    @inputNodes = for channelNumber in [1..@constructor.channelsCount]
     gainNode = new GainNode @audio.context
     gainNode.connect @masterGainNode
     gainNode
    
    # Reactively rewire master node to the named output node.
    @outputNode = new ReactiveField null
    
    @autorun (computation) =>
      if outputNode = Tracker.nonreactive => @outputNode()
        @masterGainNode.disconnect outputNode
      
      # If we have a name, we want the global output node with that name so we can wire across audio documents.
      if name = @readParameter 'name'
        outputNode = @constructor.getOutputNodeForName name, @audio.context
        
      else
        # Otherwise we want a local (anonymous) mixer node that just works inside the document.
        outputNode = new GainNode @audio.context
      
      @masterGainNode.connect outputNode
      
      @outputNode outputNode
      
    # Update gain on the master and input intermediate nodes.
    @autorun (computation) =>
      @masterGainNode.gain.value = @readParameter "masterGain"
      
    for channelNumber in [1..@constructor.channelsCount]
      do (channelNumber) =>
        @autorun (computation) =>
          channelGain = @readParameter "gain#{channelNumber}"
          @inputNodes[channelNumber - 1].gain.value = channelGain
        
  getDestinationConnection: (input) ->
    empty = super arguments...
    
    switch input
      when 'masterGain'
        destination: @masterGainNode.gain
        
      else
        connectToGain = _.startsWith input, 'gain'

        channelNumber = parseInt if connectToGain then input[4..] else input
        return empty if _.isNaN channelNumber
        
        if 1 <= channelNumber <= @constructor.channelsCount
          connection = destination: @inputNodes[channelNumber - 1]
          connection.destination = connection.destination.gain if connectToGain
          connection
          
        else
          empty
  
  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'
    
    source: @outputNode()
