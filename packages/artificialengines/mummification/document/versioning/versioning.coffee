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
