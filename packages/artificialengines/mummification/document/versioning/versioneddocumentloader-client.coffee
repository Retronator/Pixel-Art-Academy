AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedDocumentLoader
  constructor: (@versionedCollection, @id) ->
    @_documentLoadedDependency = new Tracker.Dependency
    @_loadInitialState()
    
    @_latestHistorySubscriptionHandle = @versionedCollection.documentClass.latestHistoryForId.subscribe @id

    @versionedCollection.latestHistoryDocuments.find(@id).observe
      added: (@_latestHistory) =>
      changed: (@_latestHistory) =>
    
  destroy: ->
    @_latestHistorySubscriptionHandle.stop()
  
  getDocument: ->
    @_documentLoadedDependency.depend()
    @_document
    
  _loadInitialState: ->
    @versionedCollection.documentClass.load @id, (error, result) =>
      return console.error error if error
      
      @_document = result
      @_documentLoadedDependency.changed()
      
      # If we already got some history changes, handle them.
      @_handleHistoryChanges()
  
  _handleHistoryChanges: ->
    # Nothing to do if we didn't get the initial document or history state yet.
    return unless @_document and @_latestHistory
    
    # We must make sure our local document state reflects what it is on the server.
    # See how many actions (up to history position) are matching.
    matchingActionsCount = 0
    
    for historyPosition in [@_latestHistory.historyStart...@_latestHistory.historyPosition]
      documentActionIndex = historyPosition - @_document.historyStart
      latestHistoryActionIndex = historyPosition - @_latestHistory.historyStart
      
      documentAction = @_document.history[documentActionIndex]
      latestHistoryAction = @_latestHistory.history[latestHistoryActionIndex]
      
      if EJSON.equals documentAction, latestHistoryAction
        matchingActionsCount++
        
      else
        break
        
    # If history position matches and all previous actions match, there's nothing to do.
    return if @_latestHistory.historyPosition is @_document.historyPosition and matchingActionsCount is @_latestHistory.historyPosition - @_latestHistory.historyStart
    
    # If we don't have any matching actions, we can't roll back far enough to get to a synced state, so we have to reload the document from the server.
    unless matchingActionsCount
      @_loadInitialState()
      return
    
    # If we have a partial action in progress, we need to roll back its effects.
    AM.Document.Versioning.executeOperations @_document, @_document.partialAction.backward if @_document.partialAction
    
    # Roll back all non-matching local actions.
    lastMatchingHistoryPosition = @_latestHistory.historyStart + matchingActionsCount
    
    for historyPosition in [@_document.historyPosition...lastMatchingHistoryPosition]
      documentActionIndex = historyPosition - @_document.historyStart - 1
      documentAction = @_document.history[documentActionIndex]
      
      AM.Document.Versioning.executeOperations @_document, documentAction.backward

    # Apply all non-matching latest actions.
    for historyPosition in [lastMatchingHistoryPosition...@_latestHistory.historyPosition]
      latestHistoryActionIndex = historyPosition - @_latestHistory.historyStart
      latestHistoryAction = @_latestHistory.history[latestHistoryActionIndex]
  
      AM.Document.Versioning.executeOperations @_document, latestHistoryAction.forward

    # If we have a partial action in progress, we need to apply its effects again.
    AM.Document.Versioning.executeOperations @_document, @_document.partialAction.forward if @_document.partialAction

    # Sync history fields.
    @_document.historyPosition = @_latestHistory.historyPosition
  
    lastMatchingDocumentActionIndex = lastMatchingHistoryPosition - @_document.historyStart - 1
    lastMatchingLatestHistoryActionIndex = lastMatchingHistoryPosition - @_latestHistory.historyStart - 1
    
    newActions = @_latestHistory.history[lastMatchingLatestHistoryActionIndex + 1..]
    
    @_document.history.splice lastMatchingDocumentActionIndex + 1, @_document.history.length, newActions...
