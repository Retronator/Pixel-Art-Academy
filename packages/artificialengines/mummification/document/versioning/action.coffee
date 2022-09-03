AE = Artificial.Everywhere
AM = Artificial.Mummification
AP = Artificial.Program

class AM.Document.Versioning.Action
  # operatorId: which tool generated this action (used for undo/redo description)
  # hashCode: the hash code of the action for quick equality comparison
  # forward: array of operations that creates the result of this action
  # backward: array of operations that undoes the action from the resulting state
  @pattern =
    operatorId: String
    hashCode: Number
    forward: [AM.Document.Versioning.Operation.pattern]
    backward: [AM.Document.Versioning.Operation.pattern]

  constructor: (@operatorId) ->
    @forward = []
    @backward = []

    # Call _updateHashCode in inherited actions once you set up the forward and backward operations.

  append: (action) ->
    @forward.push action.forward...
    @backward.unshift action.backward...
    @_updateHashCode()

  optimizeOperations: ->
    for operationsArray in [@forward, @backward]
      # Combine consecutive operations that are combinable.
      operationIndex = 0

      while operationIndex + 1 < operationsArray.length
        operation = operationsArray[operationIndex]
        nextOperation = operationsArray[operationIndex + 1]

        if operation.constructor.combinable and operation.id() is nextOperation.id()
          operation.combine nextOperation
          operationsArray.splice operationIndex + 1, 1

        else
          operationIndex++

    @_updateHashCode()

  _updateHashCode: ->
    # Hash all forward operations.
    @hashCode = 0

    for operation in @forward
      @hashCode = AP.HashFunctions.circularShift5 @hashCode, operation.getHashCode()
