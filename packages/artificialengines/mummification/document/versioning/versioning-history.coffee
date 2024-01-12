AE = Artificial.Everywhere
AM = Artificial.Mummification

AM.Document.Versioning.undo = (versionedDocument, lastEditTime, undoTime) ->
  @_validateActionOrder versionedDocument, lastEditTime, undoTime

  # Find history entry.
  currentHistoryPosition = versionedDocument.historyPosition
  throw new AE.InvalidOperationException "There is nothing to undo." unless currentHistoryPosition

  newHistoryPosition = currentHistoryPosition - 1
  actionToBeUndone = versionedDocument.history[newHistoryPosition]

  # Undo the action.
  @_moveInHistory versionedDocument, actionToBeUndone.backward, newHistoryPosition, undoTime
  
AM.Document.Versioning.redo = (versionedDocument, lastEditTime, redoTime) ->
  @_validateActionOrder versionedDocument, lastEditTime, redoTime

  # Find history entry.
  currentHistoryPosition = versionedDocument.historyPosition
  throw new AE.InvalidOperationException "There is nothing to redo." unless currentHistoryPosition < versionedDocument.history.length

  newHistoryPosition = currentHistoryPosition + 1
  actionToBeRedone = versionedDocument.history[currentHistoryPosition]

  # Redo the action.
  @_moveInHistory versionedDocument, actionToBeRedone.forward, newHistoryPosition, redoTime
  
AM.Document.Versioning._moveInHistory = (versionedDocument, operations, newHistoryPosition, newLastEditTime) ->
  changedFields = @executeOperations versionedDocument, operations

  # Update history.
  versionedDocument.lastEditTime = newLastEditTime
  versionedDocument.historyPosition = newHistoryPosition

  # Create the modifier that will undo the change at this position.
  modifier =
    $set:
      historyPosition: newHistoryPosition
      lastEditTime: newLastEditTime

  # We also need to send the actual changes to the fields to the database.
  @_addChangedFieldsToModifier versionedDocument, changedFields, modifier

  # Update the database document.
  versionedDocument.constructor.documents.update versionedDocument._id, modifier
  
  # On the client, raise an event that changes were made.
  versionedDocument.constructor.versionedDocuments.operationsExecuted versionedDocument, operations, changedFields if Meteor.isClient

AM.Document.Versioning.clearHistory = (versionedDocument) ->
  # Reinstate initial history state.
  _.assign versionedDocument,
    historyStart: 0
    historyPosition: 0
    history: []
    historyArchive: []

  # Update the database document.
  versionedDocument.constructor.documents.update versionedDocument._id,
    $set:
      lastEditTime: new Date
    $unset:
      historyStart: 1
      historyPosition: 1
      history: 1
      historyArchive: 1

AM.Document.Versioning.latestHistoryForId = (publishHandler, documentClass, id) ->
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
    
AM.Document.Versioning._createLocalizedHistory = (document) ->
  # TODO: Generate a localized history.
  latestHistory = _.pick document, ['lastEditTime', 'historyPosition', 'historyStart', 'history']
  
  _.defaults latestHistory,
    history: []
    historyStart: 0
    historyPosition: 0
  
  latestHistory
