LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.Node
  @_nodeClassesByType = {}

  @getClassForType: (type) ->
    @_nodeClassesByType[type]

  @getClasses: ->
    _.values @_nodeClassesByType

  # String for this node used to identify the node in code.
  @type: -> throw new AE.NotImplementedException "You must specify node's type."

  # Name is how the node is represented in the editor. Not that we can't 
  # call it simply name because it conflicts with the class name property.
  @nodeName: -> throw new AE.NotImplementedException "You must specify node's name."

  # Override to provide inputs and outputs of the node.
  @inputs: -> []
  @outputs: -> []

  @initialize: ->
    # Store node class by type.
    @_nodeClassesByType[@type()] = @
    
  constructor: (@id, @audio, initialParameters) ->
    # Parameters are compared by data equality to minimize changes in the audio engine.
    @parameters = new ReactiveField initialParameters, EJSON.equals

  destroy: ->
    # Override to dispose any web audio resources.

  type: -> @constructor.type()
  nodeName: -> @constructor.nodeName()

  connect: (node, output, input) ->
    # TODO: Actually connect the nodes.
    console.log "Connecting #{@id}:#{output} -> #{node.id}:#{input}"

  disconnect: (node, output, input) ->
    # TODO: Actually disconnect the nodes.
    console.log "Disconnecting #{@id}:#{output} -> #{node.id}:#{input}"
