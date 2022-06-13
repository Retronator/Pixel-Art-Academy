AE = Artificial.Everywhere
LOI = LandsOfIllusions
History = LOI.Assets.MeshEditor.Helpers.History

class History.Operation
  @operationName: -> throw new AE.NotImplementedException "You must specify a name for the operation."
  
  @initialize: ->
    EJSON.addType @typeName(), (json) => new @ json
    
  constructor: (@data) ->
  
  execute: (mesh) ->
    throw new AE.NotImplementedException "Operation needs to provide the code to execute itself."

  # Utility
  
  @typeName: -> "Mesh.Operation.#{@operationName()}"
  typeName: -> @constructor.typeName()
  
  toJSONValue: ->
    @data
  
  @equals: (a, b) ->
    return false unless a and b
    EJSON.equals a.data, b.data
  
  equals: (other) ->
    @constructor.equals @, other
