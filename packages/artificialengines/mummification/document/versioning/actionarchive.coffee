AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.ActionArchive extends AM.Document
  @id: -> 'Artificial.Mummification.Document.Versioning.ActionArchive'
  # profileId: the profile that owns this action archive
  # lastEditTime: the time when archive was created
  # versionedDocumentId: the ID of the document for which this action archive is for
  # historyStart: at which history position does the history array start
  # historyEnd: at which history position does the history array end
  # history: array of actions that were performed on the versioned document
  #   operatorId: which tool generated this action (used for undo/redo description)
  #   hashCode: the hash code of the action for quick equality comparison
  #   forward: array of operations that creates the result of this action
  #     id: the operation type
  #     hashCode: the hash code of the operation for quick equality comparison
  #     data: any data that defines this operation
  #   backward: array of operations that undoes the action from the resulting state
  @Meta
    name: @id()
  
  @enablePersistence()
  
  # The history length is chosen small both so that it minimizes saving times
  # on disk, but also for syncing history from the server (live updates).
  @maximumHistoryLength = 10

  @getHistoryForDocument: (versionedDocumentId) ->
    actionArchives = @documents.fetch {versionedDocumentId}
    _.flatten (actionArchive.history for actionArchive in actionArchives)
    
  @getHistoryLengthForDocument: (versionedDocumentId) ->
    lastActionArchive = @documents.findOne {versionedDocumentId},
      sort:
        historyEnd: -1
        
    return 0 unless lastActionArchive
    
    lastActionArchive.historyEnd + 1
