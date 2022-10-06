AE = Artificial.Everywhere
AM = Artificial.Mummification
AP = Artificial.Program

class AM.Document.Versioning.Operation
  @pattern = Match.Where (operation) ->
    # Note: We're using EJSON to recreate the correct operation class
    # so we need to check that it was deserialized correctly.
    operation instanceof AM.Document.Versioning.Operation

  @_operationClassesById = {}

  @id: -> throw new AE.NotImplementedException "You must specify operation's id."

  # Override for operations that can be combined with each other.
  @combinable = false

  @initialize: ->
    @_operationClassesById[@id()] = @

    EJSON.addType @typeName(), (json) =>
      operationClass = @getClassForId json.id
      operation = new operationClass EJSON.fromJSONValue json.data

      # We store the operation's hash code at serialization time to do equality comparisons faster.
      operation._hashCode = json.hashCode
      operation

  @getClassForId: (id) ->
    @_operationClassesById[id]

  @createHashCode: (object) ->
    AP.HashFunctions.getObjectHash object, AP.HashFunctions.circularShift5
    
  constructor: (properties) ->
    _.assign @, properties

  id: -> @constructor.id()

  execute: (document) ->
    # Implement to execute the operation on the document. The method should return
    # an object specifying which fields were changed (by setting their value to true).
    throw new AE.NotImplementedException "You must implement a method that changes the document."

  combine: (nextOperation) -> # Implement for operations that are combinable. This should mutate the current operation.

  # Utility

  @typeName: -> @id()
  typeName: -> @constructor.typeName()

  toJSONValue: ->
    id: @id()
    hashCode: @getHashCode()
    data: _.assignWith {}, @_getPublicFields(), (currentValue, newValue) => EJSON.toJSONValue newValue

  _getPublicFields: ->
    # Get all fields that don't start with an underscore.
    _.pickBy @, (value, key) => key[0] isnt '_'

  clone: ->
    clone = new @constructor EJSON.clone @_getPublicFields()
    clone._hashCode = @_hashCode
    clone

  @equals: (a, b) ->
    return false unless a and b
    return false unless a instanceof @ and b instanceof @

    # Generate the hash codes if they haven't been computed yet. We assume
    # that operations are not being mutated after they are initially created.
    a._hashCode ?= a.getHashCode()
    b._hashCode ?= b.getHashCode()

    a._hashCode is b._hashCode

  equals: (other) ->
    @constructor.equals @, other

  getHashCode: ->
    # Return the cached hash code if we have one. We assume operation will be fully initialized before it will be used.
    return @_hashCode if @_hashCode
  
    @_hashCode = @constructor.createHashCode @_getPublicFields()
    
    @_hashCode
