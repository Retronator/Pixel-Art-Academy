AE = Artificial.Everywhere
AM = Artificial.Mummification

AM.Document.Versioning.undo = (versionedDocument, lastEditTime, undoTime) ->
  @_validateActionOrder versionedDocument, lastEditTime, undoTime

  # Find history entry.
  currentHistoryPosition = versionedDocument.historyPosition
  throw new AE.InvalidOperationException "There is nothing to undo." unless currentHistoryPosition

  newHistoryPosition = currentHistoryPosition - 1
  actionToBeUndone = AM.Document.Versioning.getActionAtPosition versionedDocument, newHistoryPosition

  # Undo the action.
  @_moveInHistory versionedDocument, actionToBeUndone.backward, newHistoryPosition, undoTime
  
AM.Document.Versioning.redo = (versionedDocument, lastEditTime, redoTime) ->
  @_validateActionOrder versionedDocument, lastEditTime, redoTime

  # Find history entry.
  currentHistoryPosition = versionedDocument.historyPosition
  actionToBeRedone = AM.Document.Versioning.getActionAtPosition versionedDocument, currentHistoryPosition
  throw new AE.InvalidOperationException "There is nothing to redo." unless actionToBeRedone

  newHistoryPosition = currentHistoryPosition + 1

  # Redo the action.
  @_moveInHistory versionedDocument, actionToBeRedone.forward, newHistoryPosition, redoTime
  
AM.Document.Versioning.getActionAtPosition = (versionedDocument, historyPosition) ->
  # Legacy documents have history stored directly on them.
  return versionedDocument.history[historyPosition] if versionedDocument.history?[historyPosition]
  
  # New documents have history in action archives.
  actionArchive = AM.Document.Versioning.ActionArchive.documents.findOne
    versionedDocumentId: versionedDocument._id
    historyStart: $lte: historyPosition
    historyEnd: $gte: historyPosition
  
  return unless actionArchive
  
  actionArchive.history[historyPosition - actionArchive.historyStart]
  
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
  
  # Migrate history if needed.
  if versionedDocument.history
    modifier.$unset = history: true
  
    # We create action archives on the client and let them sync to the server through persistence.
    AM.Document.Versioning._migrateHistory versionedDocument if Meteor.isClient
    
  # We also need to send the actual changes to the fields to the database.
  @_addChangedFieldsToModifier versionedDocument, changedFields, modifier

  # Update the database document.
  versionedDocument.constructor.documents.update versionedDocument._id, modifier
  
  # On the client, raise an event that changes were made.
  versionedDocument.constructor.versionedDocuments.operationsExecuted versionedDocument, operations, changedFields if Meteor.isClient

AM.Document.Versioning.clearHistory = (versionedDocument) ->
  # Remove action archives.
  AM.Document.Versioning.ActionArchive.documents.remove
    versionedDocumentId: versionedDocument._id
  
  # Reinstate initial history state.
  versionedDocument.historyPosition = 0

  # Update the database document.
  versionedDocument.constructor.documents.update versionedDocument._id,
    $set:
      lastEditTime: new Date
    $unset:
      historyPosition: 1

AM.Document.Versioning._migrateHistory = (versionedDocument) ->
  return unless versionedDocument.history
  
  # Create action archives.
  for historyStart in [0...versionedDocument.history.length] by AM.Document.Versioning.ActionArchive.maximumHistoryLength
    historyEnd = Math.min(historyStart + AM.Document.Versioning.ActionArchive.maximumHistoryLength, versionedDocument.history.length) - 1
    
    AM.Document.Versioning.ActionArchive.documents.insert
      profileId: versionedDocument.profileId
      lastEditTime: versionedDocument.lastEditTime
      versionedDocumentId: versionedDocument._id
      historyStart: historyStart
      historyEnd: historyEnd
      history: versionedDocument.history[historyStart..historyEnd]
  
  delete versionedDocument.history
