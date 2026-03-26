AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning
  # Enabling versioning on a document works with the following fields on the document:
  # versioned: boolean set to true for documents that have versioning enabled (used to include in a subscription to enable versioning on the client)
  # lastEditTime: the time the last operation was applied (either through execute action or undo/redo)
  # historyPosition: how many actions brings you to the current state of the document
  # partialAction: a field on the client that holds an action that is progressively being constructed

  @initializeDocumentClass: (documentClass) ->
    documentClass.versionedDocuments = new AM.Document.Versioning.VersionedCollection documentClass

    documentClass.load = documentClass.method 'load'
    documentClass.latestHistoryForId = documentClass.subscription 'latestHistoryForId'
  
    documentClass::executeAction = (action, appendToLastAction) ->
      AM.Document.Versioning.executeAction @, @lastEditTime or @creationTime, action, new Date, appendToLastAction
  
    documentClass::undo = ->
      AM.Document.Versioning.undo @, @lastEditTime or @creationTime, new Date
  
    documentClass::redo = ->
      AM.Document.Versioning.redo @, @lastEditTime or @creationTime, new Date
      
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
