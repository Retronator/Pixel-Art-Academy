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

  # Note: The Action class doesn't get deserialized back to a rich object, so we provide
  # static methods for additional manipulation of actions beyond their construction.
  @append: (existingAction, appendedAction) ->
    existingAction.forward.push appendedAction.forward...
    existingAction.backward.unshift appendedAction.backward...
    @_updateHashCode existingAction
    
  @_updateHashCode: (action) ->
    # Hash all forward operations.
    action.hashCode = 0
    
    for operation in action.forward
      action.hashCode = AP.HashFunctions.circularShift5 action.hashCode, operation.getHashCode()
  
  constructor: (@operatorId) ->
    @forward = []
    @backward = []

    # Call _updateHashCode in inherited actions once you set up the forward and backward operations.

  append: (action) -> @constructor.append @, action

  optimizeOperations: (document) ->
    for operationsArray in [@forward, @backward]
      # Combine consecutive operations that are combinable.
      operationIndex = 0

      while operationIndex + 1 < operationsArray.length
        operation = operationsArray[operationIndex]
        nextOperation = operationsArray[operationIndex + 1]

        if operation.constructor.combinable and operation.id() is nextOperation.id()
          wasCombined = operation.combine document, nextOperation
          
          if wasCombined
            operationsArray.splice operationIndex + 1, 1
            
          else
            operationIndex++

        else
          operationIndex++

    @_updateHashCode()

  _updateHashCode: -> @constructor._updateHashCode @
