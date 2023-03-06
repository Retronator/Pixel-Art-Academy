AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning
  # Enabling versioning on a document works with the following fields on the document:
  # versioned: boolean set to true for documents that have versioning enabled (used to include in a subscription to enable versioning on the client)
  # lastEditTime: the time the last operation was applied (either through execute action or undo/redo)
  # historyPosition: how many actions brings you to the current state of the document
  # historyStart: at which history position does the history array start (the rest of the actions are in the archive)
  # history: array of actions that produce this document
  #   operatorId: which tool generated this action (used for undo/redo description)
  #   hashCode: the hash code of the action for quick equality comparison
  #   forward: array of operations that creates the result of this action
  #     id: the operation type
  #     hashCode: the hash code of the operation for quick equality comparison
  #     data: any data that defines this operation
  #   backward: array of operations that undoes the action from the resulting state
  # historyArchive: array of action archives that hold actions not included in history to reduce size
  #   url: the URL address where the array of actions is stored (in JSON format)
  #   actionsCount: how many actions are in this archive
  # partialAction: a field on the client that holds an action that is progressively being constructed

  @initializeDocumentClass: (documentClass) ->
    documentClass.versionedDocuments = new AM.Document.Versioning.VersionedCollection documentClass

    documentClass.load = documentClass.method 'load'
    documentClass.latestHistoryForId = documentClass.subscription 'latestHistoryForId'

    return unless Meteor.isServer

    documentClass.load.method (id, fields) ->
      check id, Match.DocumentId
      check fields, Match.OptionalOrNull Object

      documentClass.documents.findOne id, {fields}

    documentClass.latestHistoryForId.publish (id) ->
      check id, Match.DocumentId

      AM.Document.Versioning.latestHistoryForId @, documentClass, id

      # Explicitly return nothing since we're handling the publishing ourselves.
      return

  @executeAction: (versionedDocument, lastEditTime, action, actionTime) ->
    @_validateActionOrder versionedDocument, lastEditTime, actionTime
    
    # Execute the action on the document, unless it was already executed with partial actions.
    if versionedDocument.partialAction
      # We assume all operations of action have already been applied through partial
      # execution and we can just remove the partial action to signify it's been fully applied.
      delete versionedDocument.partialAction
      
    else
      changedFields = @executeOperations versionedDocument, action.forward
  
    # Change history.
    currentHistoryPosition = versionedDocument.historyPosition or 0
    newHistoryPosition = currentHistoryPosition + 1

    if Meteor.isClient
      # On the client we simply modify the fields of the versioned document.
      versionedDocument.lastEditTime = actionTime
      versionedDocument.historyPosition = newHistoryPosition
      versionedDocument.history ?= []
      versionedDocument.history.splice currentHistoryPosition if versionedDocument.history.length > currentHistoryPosition
      versionedDocument.history.push action
      
    else
      # On the server we apply changes to the database.
      modifier =
        $set:
          historyPosition: newHistoryPosition
          lastEditTime: actionTime
        $push:
          history:
            $position: currentHistoryPosition
            $each: [action]
            $slice: newHistoryPosition
        
      # We also need to send the actual changes to the fields to the database.
      @_addChangedFieldsToModifier versionedDocument, changedFields, modifier
      
      # Update the database document.
      versionedDocument.constructor.documents.update versionedDocument._id, modifier
      
  @_validateActionOrder: (versionedDocument, lastEditTime, newLastEditTime) ->
    # If we have no last edit time we use the creation time.
    documentLastEditTime = versionedDocument.lastEditTime or versionedDocument.creationTime
    
    # Make sure the action is trying to be applied on the correct version of the document.
    throw new AE.InvalidOrderException "The current version of the document is ahead of the client." if documentLastEditTime > lastEditTime
    throw new AE.InvalidOrderException "The action is being applied on a version of the document that is behind the client." if documentLastEditTime < lastEditTime
    throw new AE.InvalidOrderException "The action must be applied at a later time than the document last edit time." unless newLastEditTime > documentLastEditTime
    throw new AE.InvalidOrderException "The time on the client is more than 10s different than the time on the server." if Math.abs(newLastEditTime.getTime() - Date.now()) > 10000

  @_addChangedFieldsToModifier: (versionedDocument, changedFields, modifier) ->
    traverseChangedFields = (path, node) =>
      # See if we've reached a leaf node.
      if _.isObject node
        # Traverse all node children.
        for name, child of node
          newPath = [path..., name]
          traverseChangedFields newPath, child

      else
        address = path.join '.'
        value = _.nestedProperty versionedDocument, address
        
        # Convert all rich objects to plain objects.
        toPlainObject = (value) ->
          return value unless _.isObject value
          
          # EJSON types are left as-is since they will be converted automatically.
          return value if value.toJSONValue or EJSON.isBinary value
          
          # See if the object provides its own plain object conversion.
          object = value
          return object.toPlainObject() if object.toPlainObject
  
          # Arrays require special iteration.
          return (toPlainObject element for element in value) if _.isArray value
          
          # Convert all properties of the object to plain objects.
          plainObject = {}
          
          for key, value of object
            plainObject[key] = toPlainObject value
  
          plainObject
  
        value = toPlainObject value
        
        if value is undefined
          modifier.$unset ?= {}
          modifier.$unset[address] = true
          
        else
          modifier.$set[address] = value

    traverseChangedFields [], changedFields
  
  @executePartialAction: (versionedDocument, action) ->
    @executeOperations versionedDocument, action.forward
    
    if versionedDocument.partialAction
      # This is a continuation of a partial action so merge it to the previous one.
      versionedDocument.partialAction.forward.push action.forward...
      versionedDocument.partialAction.backward.unshift action.backward...
      
    else
      # This is the start of a partial action.
      versionedDocument.partialAction = action
  
  @executeOperations: (versionedDocument, operations) ->
    # Execute the operations and track which fields were changed.
    allChangedFields = for operation in operations
      changedFields = operation.execute versionedDocument

      # On the client, raise an event that changes were made.
      versionedDocument.constructor.versionedDocuments.operationExecuted versionedDocument, operation, changedFields if Meteor.isClient
  
      changedFields
      
    # Merge all changed fields, giving priority to changes of the whole field over partial ones.
    _.mergeWith {}, allChangedFields..., (targetField, sourceField) ->
      # A true value signifies the field as a whole has been changed.
      return true if targetField is true or sourceField is true
      
      # Do a normal merge of sub-fields.
      undefined
      
  @reportExecuteActionError: (versionedDocument) ->
    versionedDocument.constructor.versionedDocuments.reportExecuteActionError versionedDocument._id
    
  @undo: (versionedDocument, lastEditTime, undoTime) ->
    @_validateActionOrder versionedDocument, lastEditTime, undoTime

    # Find history entry.
    currentHistoryPosition = versionedDocument.historyPosition
    throw new AE.InvalidOperationException "There is nothing to undo." unless currentHistoryPosition
  
    newHistoryPosition = currentHistoryPosition - 1
    actionToBeUndone = versionedDocument.history[newHistoryPosition]
  
    # Undo the action.
    @_moveInHistory versionedDocument, actionToBeUndone.backward, newHistoryPosition, undoTime
    
  @redo: (versionedDocument, lastEditTime, redoTime) ->
    @_validateActionOrder versionedDocument, lastEditTime, redoTime

    # Find history entry.
    currentHistoryPosition = versionedDocument.historyPosition
    throw new AE.InvalidOperationException "There is nothing to redo." unless currentHistoryPosition < versionedDocument.history.length
  
    newHistoryPosition = currentHistoryPosition + 1
    actionToBeRedone = versionedDocument.history[currentHistoryPosition]
  
    # Redo the action.
    @_moveInHistory versionedDocument, actionToBeRedone.forward, newHistoryPosition, redoTime
    
  @_moveInHistory: (versionedDocument, operations, newHistoryPosition, newLastEditTime) ->
    changedFields = @executeOperations versionedDocument, operations
  
    # Update history.
    if Meteor.isClient
      versionedDocument.lastEditTime = newLastEditTime
      versionedDocument.historyPosition = newHistoryPosition
  
    else
      # Create the modifier that will undo the change at this position.
      modifier =
        $set:
          historyPosition: newHistoryPosition
          lastEditTime: newLastEditTime
    
      # We also need to send the actual changes to the fields to the database.
      @_addChangedFieldsToModifier versionedDocument, changedFields, modifier
    
      # Update the database document.
      versionedDocument.constructor.documents.update versionedDocument._id, modifier

  @latestHistoryForId: (publishHandler, documentClass, id) ->
    collectionName = documentClass.versionedDocuments.latestHistoryCollectionName
    
    # Retrieve the latest version of the document with provided id.
    documentClass.documents.find(
      id
    ,
      fields:
        lastEditTime: 1
        historyPosition: 1
        historyStart: 1
        history: 1
    ).observe
      added: (document) =>
        publishHandler.added collectionName, document._id, @_createLocalizedHistory document
        publishHandler.ready()
        
      changed: (document) =>
        publishHandler.changed collectionName, document._id, @_createLocalizedHistory document
        
      removed: (document) =>
        publishHandler.removed collectionName, document._id
      
  @_createLocalizedHistory: (document) ->
    # TODO: Generate a localized history.
    latestHistory = _.pick document, ['lastEditTime', 'historyPosition', 'historyStart', 'history']
    
    _.defaults latestHistory,
      history: []
      historyStart: 0
      historyPosition: 0
    
    latestHistory
