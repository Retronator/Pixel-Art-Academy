AE = Artificial.Everywhere
LOI = LandsOfIllusions
History = LOI.Assets.MeshEditor.Helpers.History

class History.Action
  @actionName: -> throw new AE.NotImplementedException "You must specify a name for the action."

  @initialize: ->
    EJSON.addType @typeName(), (json) => new @ json

  constructor: (data) ->
    @_forwardSequence = data?.forwardSequence or []
    @_backwardSequence = data?.backwardSequence or []
    
  generateOperations: ->
    throw new AE.NotImplementedException "Action has to generate forward and backward sequences."

  executeForward: (mesh) -> @_executeSequence mesh, @_forwardSequence
  executeBackward: (mesh) -> @_executeSequence mesh, @_backwardSequence
  
  _executeSequence: (mesh, sequence) ->
    operation.execute mesh for operation in sequence

  # Utility
  
  @typeName: -> "Mesh.Action.#{@actionName()}"
  typeName: -> @constructor.typeName()
  
  toJSONValue: ->
    forwardSequence: @_forwardSequence
    backwardSequence: @_backwardSequence
  
  @equals: (a, b) ->
    return false unless a and b
    EJSON.equals a.forwardSequence, b.forwardSequence
    EJSON.equals a.backwardSequence, b.backwardSequence
  
  equals: (other) ->
    @constructor.equals @, other
